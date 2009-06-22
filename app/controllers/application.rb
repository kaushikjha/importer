# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :redirect_shopifyapps_to_heroku

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ee80264b012d5ea85351698811b94607'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  # This allows text helpers to be used in flash messages
  def help
    Helper.instance
  end
  
  def redirect_shopifyapps_to_heroku
    if request.domain =~ /shopifyapps/
      redirect_to "http://importer.heroku.com#{request.request_uri}"
    end
  end
    
  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end
  
end
