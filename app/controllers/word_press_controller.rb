class WordPressController < ApplicationController

  around_filter :shopify_session

  def index
    redirect_to :action => 'new'
  end
  
  def new
  end

  def create
    begin
      @import = WordPressImport.new(params[:import])
      @import.site = current_shop.url

      flash[:error] = "Error importing your blog. Wrong file type." unless @import.write_file
      if @import.save
        @import.guess
      else
        flash[:error] = "Error importing your blog." unless flash[:error]
        render :action => "new"
      end
    
    rescue NameError => e
      flash[:error] = "The type of import that you are attempting is not currently supported."
      render :action => "new"
    rescue REXML::ParseException => e
      flash[:error] = "Error importing blog. Your file is not valid XML."      
      render :action => "new"
    end
  end

  def import
    begin
      # Find the import job 
      @import = WordPressImport.find(params[:id])
      unless @import.site == current_shop.url
        raise ActiveRecord::RecordNotFound
      end
      @import.execute! 
    rescue REXML::ParseException => e
      flash[:error] = "Error importing blog. Your file is not valid XML."
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = "Error importing blog. The data could not be saved."
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = "Either the import job that you are attempting to run does not exist or you are attempting to run someone else's import job..."
    rescue NameError => e
      flash[:error] = "The type of import that you are attempting may not be currently supported."
    else
      flash[:notice] = "Blog successfully imported! You have imported " + help.pluralize(@import.posts, 'blog post') + ", " + help.pluralize(@import.pages, 'page') + ", and " + help.pluralize(@import.comments, 'comment') + ", with #{@import.skipped} skipped."      
    end
    
    respond_to do |format|
      format.html { redirect_to :controller => 'dashboard', :action => 'index' }
      format.js { render :partial => 'import' }
    end
  end
  
end