module Authenticable 
	#Devise methods overwrites
	def current_user 
		@current_user ||= User.find_by(auth_token: request.headers['HTTP_AUTHORIZATON'])
	end
	
	def authenticate_with_token!
		render json: { errros: "Not authenticated" }, 
		              status: :unauthorized unless current_user.present? 
	end
end