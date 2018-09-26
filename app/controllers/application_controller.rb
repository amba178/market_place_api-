class ApplicationController < ActionController::API
	 # protect_from_forgery with: :null_session
	  # protect_from_forgery with: :null_session
	  # before_action :authenticate_user!
	 include Authenticable 
end
