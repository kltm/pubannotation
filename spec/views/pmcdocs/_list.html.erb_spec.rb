# encoding: utf-8
require 'spec_helper'

describe "pmcdocs/_list.html.erb" do
  describe 'search form' do
    before do
      view.stub(:project).and_return(nil)
      view.stub(:docs).and_return([])
      view.stub(:will_paginate).and_return(nil)
    end
    
    context 'when @project present' do
      before do
        @project = FactoryGirl.create(:project)
        assign :project, @project
        @id = 'params_id'
        view.stub(:params).and_return({:id => @id})
        @pmc_sourceid_value = 'pmc_sourceid_value'
        assign :pmc_sourceid_value, @pmc_sourceid_value
        @pmc_body_value = 'pmc_body_value'
        assign :pmc_body_value, @pmc_body_value
        render
      end
      
      it 'should render search project form' do
        rendered.should have_selector :form, :action => search_project_path(@project.name)
      end
      
      it 'should render autocomplete for project with @pmc_sourceid_value value' do
        rendered.should have_selector :input, :id => 'sourceid', :value => @pmc_sourceid_value, 'data-autocomplete' => "/projects/autocomplete_pmcdoc_sourceid/#{@id}"
      end
      
      it 'should render body textfield with @pmc_body_value value' do
        rendered.should have_selector :input, :id => 'body', :value => @pmc_body_value
      end
    end
    
    context 'when @project blank' do
      before do
        render
      end
      
      it 'should render search pmcdocs form' do
        rendered.should have_selector :form, :action => search_pmcdocs_path
      end
      
      it 'should render autocomplete for pmcdocs' do
        rendered.should have_selector :input, :id => 'sourceid', 'data-autocomplete' => autocomplete_doc_sourceid_pmcdocs_path
      end
    end
  end
end