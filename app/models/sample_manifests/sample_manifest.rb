require 'roo'
class SampleManifest < ActiveRecord::Base
  
  belongs_to :client
  has_many :biofluid_sample_manifests, :dependent => :destroy
  has_many :tissue_sample_manifests, :dependent => :destroy
  has_many :cell_sample_manifests, :dependent => :destroy

  has_attached_file :file
  
  has_many :stored_files, :as => :attachable
  accepts_nested_attributes_for :stored_files, :allow_destroy => true

  accepts_nested_attributes_for :biofluid_sample_manifests, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :tissue_sample_manifests, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :cell_sample_manifests, :allow_destroy => true, :reject_if => :all_blank
  
  after_save :parse_file
  
  
  def parse_file
    if file.exists?
        file_name = File.basename( file.path, ".*" )
        dir = File.dirname(file.path)
        file_path = dir + "/#{file_name}.xlsx"
        File.rename(file.path,file_path)      
        workbook = Roo::Excelx.new(file_path);
        workbook.default_sheet = workbook.sheets[2]
        self.title = workbook.cell(6,2)
        (19..workbook.last_row).each do |row|
          if (!workbook.row(row)[2].nil?)
             sample = self.cell_sample_manifests.build
             sample.tube_id = workbook.row(row)[0]
             sample.cell_line = workbook.row(row)[2]
             sample.group_id = workbook.row(row)[3]
             sample.viable_cells = workbook.row(row)[4]
             (6..10).each do |num|
               if !workbook.row(row)[num].nil?
                  set_module sample,num - 5
                end
             end   
           end
        end
        workbook.default_sheet = workbook.sheets[0]
         (19..workbook.last_row).each do |row|
          if (!workbook.row(row)[3].nil?)
             sample = self.tissue_sample_manifests.build
             sample.tube_id = workbook.row(row)[0]
             sample.species = workbook.row(row)[1]
             sample.group_id = workbook.row(row)[3]
             sample.tissue_weight = workbook.row(row)[4]
             (6..10).each do |num|
               if !workbook.row(row)[num].nil?
                  set_module sample,num - 5
                end
             end   
           end
        end
         workbook.default_sheet = workbook.sheets[1]
         (19..workbook.last_row).each do |row|
          if (!workbook.row(row)[1].nil?)
             sample = self.biofluid_sample_manifests.build
             sample.tube_id = workbook.row(row)[0]
             sample.species = workbook.row(row)[1]
             sample.group_id = workbook.row(row)[3]
             sample.sample_volume = workbook.row(row)[4]
             (6..10).each do |num|
               if !workbook.row(row)[num].nil?
                  set_module sample,num - 5
                end
             end   
           end
        end
        self.file = nil #discard after parseing
        self.save!     
      end 
  end
  
  
  def total_samples
    self.biofluid_sample_manifests.count + self.tissue_sample_manifests.count + self.cell_sample_manifests.count
  end 
  
  def total_tests
    total = 0
    self.biofluid_sample_manifests.each do |s|
      total += s.tests
    end
    self.tissue_sample_manifests.each do |s|
      total += s.tests
    end
    self.cell_sample_manifests.each do |s|
      total += s.tests
    end

    total
  end
  
  def estimate
    total = 0
    self.biofluid_sample_manifests.each do |s|
      total += s.estimate
    end
    self.tissue_sample_manifests.each do |s|
      total += s.estimate
    end
    self.cell_sample_manifests.each do |s|
      total += s.estimate
    end

    total
  end

  def self.module_codes(manifest)
    codes = []
    codes << "MP#1" if manifest.module_1?
    codes << "MP#2" if manifest.module_2?
    codes << "MP#3" if manifest.module_3?
    codes << "MP#4" if manifest.module_4?
    codes << "MP#5" if manifest.module_5?
    codes << "GC-FAP" if manifest.gc_fap?
    codes << "SS#1" if manifest.ss_1?
    codes << "SS#2" if manifest.ss_2?
    codes
  end
  private
  def set_module(sample,num)
    case 
      when num == 1
        sample.module_1 = true
      when num == 2
        sample.module_2 = true
      when num == 3
        sample.module_3 = true
      when num == 4
        sample.module_4 = true
      when num == 5
        sample.module_5 = true
    end
  end
end