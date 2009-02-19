class Sample < ActiveRecord::Base
  belongs_to :animal
  belongs_to :sample
  belongs_to :site
  belongs_to :collected_by, :class_name => 'User'
  
  has_many :samples, :dependent => :destroy
  has_many :experiments, :dependent => :destroy
  
  has_many :cohort_assignments, :as => :assignable, :dependent => :destroy
  has_many :cohorts, :through => :cohort_assignments
  
  validates_numericality_of :original_amount, :greater_than_or_equal => 0, :allow_blank => true
  # validates_inclusion_of :original_unit, :in => ['ml', 'g'], :allow_blank => true
  validates_numericality_of :actual_amount, :greater_than_or_equal => 0, :allow_blank => true
  # validates_inclusion_of :actual_unit, :in => ['ml', 'g'], :allow_blank => true

  # belongs_to :collected_by, :class_name => 'User', :foreign_key => 'collected_by_id'
  
  # Required so that Experiments, Samples, and Animals can be displayed in cohorts
  def to_s
    return "#{self.barcode} (#{sample_type} - #{original_amount} #{original_unit})"
  end
  
  def validate
    if (animal and animal.birthdate and collected_on and animal.birthdate > collected_on)
      errors.add(:collected_on, "The sample cannot be taken before the animal's birth date")
    end
  end

  def before_validation
    self.sample_type = self.sample.sample_type if self.sample
  end
  
  def root
    current_sample = self
    while current_sample.animal.nil?
      current_sample = current_sample.sample
    end
    current_sample.animal
  end

  # calculates the theoretical amount of this sample = original amount - sum(original amount of each child)
  #
  # assumes that original_unit for this sample and all children are the same
  def theoretical_amount
    theoretical = self.original_amount
    self.samples.each do |child|
      theoretical -= child.original_amount
    end
    theoretical
  end
  
  def parent
    self.animal || self.sample
  end
  
  def aliquot?
    return !self.sample.blank?
  end
end
