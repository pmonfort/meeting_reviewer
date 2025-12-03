class AnalysisController < ApplicationController
  def new
  end

  def create
    @analysis = Analysis.new(analysis_params)
    if @analysis.save
      redirect_to @analysis
    else
      render :new
    end
  end

  private

  def analysis_params
    params.require(:analysis).permit(:name, :description)
  end
end
