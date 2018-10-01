require 'spec_helper'

describe Api::V1::ProductsController, type: :controller do

   describe "GET #show" do
   	 before(:each) do
      	@product = FactoryBot.create :product
     	 get :show, params: {id: @product.id}, format: :json 
     end

     it "has the user as a embeded object" do 
      product_response = json_response
      # byebug
      expect(product_response[:user][:email]).to eql @product.user.email 
     end

    it "returns the information about a reporter on a hash" do
      product_response = json_response
      expect(product_response[:title]).to eql @product.title
    end

       it { should respond_with 200 }
    end


    describe "GET #index" do 
    	before(:each) do 
    		4.times { FactoryBot.create :product }
    		get :index 
    	end

      it "returns the user object into each product" do 
        products_response = json_response
        products_response.each do |product_response|
          expect(product_response[:user]).to be_present  
        end
      end

    	it "returns 4 records from the database" do 
    		products_response = json_response
    		# byebug
    		expect(products_response.size).to eql 4
    	end
    	it {should respond_with 200 }
    end


    describe "POST #create" do
    	context "when is successfully created" do
      		before(:each) do
        		user = FactoryBot.create :user
        		@product_attributes = FactoryBot.attributes_for :product
        		api_authorization_header user.auth_token
        		post :create, params: { user_id: user.id, product: @product_attributes }
      		end

      		it "renders the json representation for the product record just created" do
        		product_response = json_response
        		expect(product_response[:title]).to eql @product_attributes[:title]
      		end
      	end
    end


    describe "PUT/PATCH #update" do
    	before(:each) do
     	 	@user = FactoryBot.create :user
      		@product = FactoryBot.create :product, user: @user
      		api_authorization_header @user.auth_token
    	end

    context "when is successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
              product: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        product_response = json_response
        expect(product_response[:title]).to eql "An expensive TV"
      end

      it { should respond_with 201 }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
              product: { price: "two hundred" } }
      end

      it "renders an errors json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }
    end
  end


  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryBot.create :user
      @product = FactoryBot.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @product.id }
    end

    it { should respond_with 204 }
  end


  describe ".filter_by_title" do 
    before(:each) do 
      @product1 = FactoryBot.create :product, title: "A plasma TV"
      @product2 = FactoryBot.create :product, title: "Fastest Laptop"
      @product3 = FactoryBot.create :product, title: "CD player"
      @product4 = FactoryBot.create :product, title: "LCD TV"
    end

    context "when a 'TV' title pattern is sent" do 
      it "return the 2 products matching"  do
        expect(Product.filter_by_title('TV').size).to eql 2 
      end

      it "returns the products matching" do
        expect(Product.filter_by_title("TV").sort).to match_array([@product1, @product4])
      end

    end
  end


  describe ".above_or_equal_to_price" do
    before(:each) do
      @product1 = FactoryBot.create :product, price: 100
      @product2 = FactoryBot.create :product, price: 50
      @product3 = FactoryBot.create :product, price: 150
      @product4 = FactoryBot.create :product, price: 99
    end

    it "returns the products which are above or equal to the price" do
      expect(Product.above_or_equal_to_price(100).sort).to match_array([@product1, @product3])
    end

    it "returns the products which are above or equal to the price" do
      expect(Product.below_or_equal_to_price(99).sort).to match_array([@product2, @product4])
    end
  end


  describe ".recent" do
    before(:each) do
      @product1 = FactoryBot.create :product, price: 100
      @product2 = FactoryBot.create :product, price: 50
      @product3 = FactoryBot.create :product, price: 150
      @product4 = FactoryBot.create :product, price: 99

      #we will touch some products to update them
      @product2.touch
      @product3.touch
    end

    it "returns the most updated records" do
      expect(Product.recent).to match_array([@product3, @product2, @product4, @product1])
    end
  end


  describe ".search" do
    before(:each) do
      @product1 = FactoryBot.create :product, price: 100, title: "Plasma tv"
      @product2 = FactoryBot.create :product, price: 50, title: "Videogame console"
      @product3 = FactoryBot.create :product, price: 150, title: "MP3"
      @product4 = FactoryBot.create :product, price: 99, title: "Laptop"
    end
    context "when title 'videogame' and '100' a min price are set" do
      it "returns an empty array" do
        search_hash = { keyword: "videogame", min_price: 100 }
        expect(Product.search(search_hash)).to be_empty
       
      end

    end

  end

end
