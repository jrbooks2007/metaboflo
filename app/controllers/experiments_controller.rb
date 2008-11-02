class ExperimentsController < ApplicationController
  before_filter :find_sample
  
  # GET /experiments
  # GET /experiments.xml
  def index
    if @sample
      @experiments = @sample.experiments
    else
      @experiments = Experiment.find(:all)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @experiments }
    end
  end

  # GET /experiments/1
  # GET /experiments/1.xml
  def show
    @experiment = Experiment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @experiment }
    end
  end

  # GET /experiments/new
  # GET /experiments/new.xml
  def new
    @experiment = Experiment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @experiment }
    end
  end

  # GET /experiments/1/edit
  def edit
    @experiment = Experiment.find(params[:id])
  end

  # POST /experiments
  # POST /experiments.xml
  def create
    @experiment = Experiment.new(params[:experiment])
    @experiment.sample = @sample

    respond_to do |format|
      if @experiment.save
        flash[:notice] = 'Experiment was successfully created.'
        format.html { redirect_to(@experiment) }
        format.xml  { render :xml => @experiment, :status => :created, :location => @experiment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @experiment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /experiments/1
  # PUT /experiments/1.xml
  def update
    @experiment = Experiment.find(params[:id])

    respond_to do |format|
      if @experiment.update_attributes(params[:experiment])
        flash[:notice] = 'Experiment was successfully updated.'
        format.html { redirect_to(@experiment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @experiment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.xml
  def destroy
    @experiment = Experiment.find(params[:id])
    @experiment.destroy

    respond_to do |format|
      format.html { redirect_to(experiments_url) }
      format.xml  { head :ok }
    end
  end
  
  private 
  def find_sample
    if params[:sample_id]
      @sample = Sample.find(params[:sample_id])
      #@patient = @sample.patient
    elsif ['new', 'create'].include?(action_name)
      flash[:notice] = "Sample must be specified."
      respond_to do |format|
        format.html { redirect_to experiments_url }
        format.xml { redirect_to formatted_experiments_url }
      end
    end
  end
end