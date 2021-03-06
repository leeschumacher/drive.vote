require "rails_helper"

RSpec.describe Admin::UsersController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/users").to route_to("admin/users#index")
    end

    it "routes to #show" do
      expect(:get => "admin/users/1").to route_to("admin/users#show", :id => "1")
    end

    it "routes to #qa_clear" do
      expect(:post => "admin/users/1/qa_clear").to route_to("admin/users#qa_clear", :id => "1")
    end

    # it "routes to #new" do
    #   expect(:get => "/users/new").to route_to("users#new")
    # end
    #

    # it "routes to #edit" do
    #   expect(:get => "/users/1/edit").to route_to("users#edit", :id => "1")
    # end
    #
    # it "routes to #create" do
    #   expect(:post => "/users").to route_to("users#create")
    # end
    #
    # it "routes to #update" do
    #   expect(:put => "/users/1").to route_to("users#update", :id => "1")
    # end
    #
    # it "routes to #destroy" do
    #   expect(:delete => "/admin/users/1").to route_to("admin/users#destroy", :id => "1")
    # end

  end
end
