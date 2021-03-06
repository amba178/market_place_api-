# require 'spec_helper'

describe Api::V1::UsersController do
    
    #Mime::JSON replaced with 'application/json'
	# before(:each) { request.headers['Accept'] = "application/vnd.marketplace.v1, applicaion/json"} 
	# before(:each) { request.headers['Content-Type'] = "application/json"}

describe "POST #create " do 

  	context "when is successfully created" do 
  		before(:each) do 
  		   @user_attributes = FactoryBot.attributes_for :user 
  		   post :create, params:  { user: @user_attributes} , format: :json
  	    end
        
            it "has the product ids as an embeded object" do 
            
              user_response = json_response 
   
              expect(user_response[:products]).to eql []
         end
      

  	    it "renders the json representation for the user record just created" do
        	user_response = json_response
        	expect(user_response[:email]).to eql @user_attributes[:email]
    	end

    	it { should respond_with 201 }

  	end
 

  context "When is not created" do 
  	before(:each) do 
  		@user_attributes =  { password: "12345678",
                                     password_confirmation: "12345678" }
  		post :create, params: {user: @user_attributes }, format: :json
  	end
  	it "renders an errors json" do 
  		user_response = json_response
  		expect(user_response).to have_key(:errors)
  	end

  	it "renders the json errors on why the user could not be created" do 
  		user_response = json_response
  		expect(user_response[:errors][:email]).to include "can't be blank"
  	end
  end
end

  describe "GET #show" do
    before(:each) do
      @user = FactoryBot.create :user

      get :show, params: {id: @user.id} , format: :json
    end

    it "returns the information about a reporter on a hash" do
      user_response = json_response
      expect(user_response[:email]).to eql @user.email
    end

    it { should respond_with 200 }
  end

  describe "PUT/PATCH #update" do

    context "when is successfully updated" do
      before(:each) do
        @user = FactoryBot.create :user
        request.headers['Authorizaton'] = @user.auth_token
        patch :update, params: { id: @user.id,
                         user: { email: "newmail@example.com" } }, format: :json
      end

      it "renders the json representation for the updated user" do
        user_response = json_response
        expect(user_response[:email]).to eql "newmail@example.com"
      end

      it { should respond_with 200 }
    end

    context "when is not created" do
      before(:each) do
        @user = FactoryBot.create :user
        request.headers['Authorizaton'] = @user.auth_token
        patch :update, params: { id: @user.id,
                         user: { email: "newmail.com" } }, format: :json
      end

      it "renders an errors json" do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        user_response =json_response
        expect(user_response[:errors][:email]).to include "is invalid"
      end

      it { should respond_with 422 }
    end
  end


  describe "DELETE #destroy" do
 	 before(:each) do
    	@user = FactoryBot.create :user
    	request.headers['Authorizaton'] = @user.auth_token
    	delete :destroy, params: { id: @user.id }, format: :json
  	end
  	it { should respond_with 204} 
  end

end
