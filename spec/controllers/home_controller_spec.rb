# encoding: utf-8
require 'spec_helper'

describe HomeController do
  describe 'index' do
    before do
      @current_user = FactoryGirl.create(:user)
      current_user_stub(@current_user)
      @source_dbs = ['source_dbs']
      Doc.stub(:source_dbs).and_return(@source_dbs)
      @accessble_projects = double(:accessible)
      Project.stub(:accessible).and_return(@accessble_projects)
      @sort_by_params = 'sort_by_params'
      @accessble_projects.stub(:sort_by_params).and_return(@sort_by_params)
    end
    
    it '@source_dbs should eql Doc.source_dbs' do
      get :index
      assigns[:source_dbs].should eql @source_dbs
    end
    
    it 'should call sort_order with Project' do
      controller.should_receive(:sort_order).with(Project)
      get :index
    end
    
    it '@projects should eql Project.order_by' do
      get :index
      assigns[:projects].should eql(@sort_by_params)
    end
  end
end
