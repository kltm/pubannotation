# encoding: utf-8
require 'spec_helper'

describe DivsController do
  describe 'index' do
    before do
      @pmcdoc_id = 'sourceid'
      @doc_pmc_sourceid = FactoryGirl.create(:doc, :sourcedb => 'PMC', :sourceid => @pmcdoc_id)
      @doc_not_pmc = FactoryGirl.create(:doc, :sourcedb => 'AAA', :sourceid => @pmcdoc_id)
      @project_id = 'project id'
    end
    
    context 'when format html' do
      before do
        get :index, :pmcdoc_id => @pmcdoc_id, :project_id => @project_id
      end
      
      it '@docs should include only sourcede == PMC and sourceid == params[:pmcdoc_id]' do
        assigns[:docs].should include(@doc_pmc_sourceid)      
        assigns[:docs].should_not include(@doc_not_pmc) 
      end
      
      it '@project_name should be same as params[:project_id]' do
        assigns[:project_name].should eql(@project_id)
      end
      
      it 'should render template' do
        response.should render_template('index')
      end
    end

    context 'when format json' do
      before do
        get :index, :format => 'json', :pmcdoc_id => @pmcdoc_id, :project_id => @project_id
      end
      
      it 'should render json' do
        response.body.should eql(assigns[:docs].to_json)
      end
    end
  end
  
  describe 'show' do
    before do
      @id = 'id'
      @pmcdoc_id = 'pmc doc id'
      @asciitext = 'aschii text'
      @doc = FactoryGirl.create(:doc)
      @project = FactoryGirl.create(:project)
      @get_doc_notice = 'get doc notice'
    end
    
    context 'when params[:project_id] does not exists' do
      context 'when encoding ascii' do
        before do
          controller.stub(:get_doc).and_return([@doc, @get_doc_notice])
          @get_projects_notice = 'get projects notice'
          controller.stub(:get_projects).and_return([@project, @get_projects_notice])
          controller.stub(:get_ascii_text).and_return(@asciitext)
        end
        context 'when format html' do
          before do
            get :show, :encoding => 'ascii', :pmcdoc_id => @pmcdoc_id, :id => @id
          end
          
          it 'should set get_projects_notice as flash[:notice]' do
            flash[:notice].should eql(@get_doc_notice)  
          end
          
          it 'should render template' do
            response.should render_template('docs/show')
          end
        end

        context 'when format json' do
          before do
            get :show, :encoding => 'ascii', :format => 'json', :pmcdoc_id => @pmcdoc_id, :id => @id
          end
          
          it 'should render json' do
            hash = {
              :pmcdoc_id => @pmcdoc_id,
              :div_id => @id,
              :text => @asciitext
            }
            response.body.should eql(hash.to_json)
          end
        end
        
        context 'when format txt' do
          before do
            get :show, :encoding => 'ascii', :format => 'txt', :pmcdoc_id => @pmcdoc_id, :id => @id
          end
          
          it 'should render ascii text' do
            response.body.should eql(@asciitext)
          end
        end
      end
    end
    
    context 'when params[:project_id] exists' do
      before do
        @project_id = 'project id'
        @get_project_notice = 'get project notice'
      end
      
      context 'when get_project returns project' do
        before do
          controller.stub(:get_project).and_return([@project, @get_project_notice])
        end
        
        context 'get_doc return doc' do
          before do
            controller.stub(:get_doc).and_return([@doc, @get_doc_notice])
            get :show, :project_id => @project_id, :pmcdoc_id => @pmcdoc_id, :id => @id
          end
          
          it '@text should same as @doc.body' do
            assigns[:text].should eql(@doc.body)
          end
          
          it 'should set get_doc notice as flash[:notice]' do
            flash[:notice].should eql(@get_doc_notice)  
          end
          
          it 'should render template' do
            response.should render_template('docs/show')
          end
        end     
      end
      
      context 'when get_project does not returns project' do
        before do
          controller.stub(:get_project).and_return([nil, @get_project_notice])
        end
        
        context 'when format html' do
          before do
            get :show, :project_id => @project_id, :pmcdoc_id => @pmcdoc_id, :id => @id
          end

          it '@doc should be nil' do
            assigns[:doc].should be_nil
          end  
          
          it 'should redirect to pmcdocs_path' do
            response.should redirect_to(pmcdocs_path)
          end
          
          it 'should set flash[:notice]' do
            flash[:notice].should eql(@get_project_notice)
          end
        end  
        
        context 'when format json' do
          before do
            get :show, :format => 'json', :project_id => @project_id, :pmcdoc_id => @pmcdoc_id, :id => @id
          end

          it 'should returns status 422' do
            response.status.should eql(422)
          end  
        end  
        
        context 'when format json' do
          before do
            get :show, :format => 'txt', :project_id => @project_id, :pmcdoc_id => @pmcdoc_id, :id => @id
          end

          it 'should returns status 422' do
            response.status.should eql(422)
          end  
        end  
      end
    end
  end
  
  describe 'new' do
    before do
      @pmcdoc_id = 'pmcdoc id'  
    end
    
    context 'format html' do
      before do
        get :new, :pmcdoc_id => @pmcdoc_id
      end
      
      it '@doc should be new record' do
        assigns[:doc].new_record?.should be_true
      end
      
      it '@doc.sourceid should equal params[:pmcdoc_id]' do
        assigns[:doc].sourceid.should eql(@pmcdoc_id)
      end
      
      it '@doc.source should equal url and params[:pmcdoc_id]' do
        assigns[:doc].source.should eql('http://www.ncbi.nlm.nih.gov/pmc/' + @pmcdoc_id)
      end
    end
    
    context 'format html' do
      before do
        get :new, :format => 'json', :pmcdoc_id => @pmcdoc_id
      end
      
      it 'should render @doc as json' do
        response.body.should eql(assigns[:doc].to_json)
      end
    end
  end
  
  describe 'edit' do
    before do
      @doc = FactoryGirl.create(:doc)
      @notice = 'notice'
      controller.stub(:get_doc).and_return(@doc, @notice)
      get :edit, :pmcdoc_id => '', :id => ''
    end
    
    it '@doc should get_doc' do
      assigns[:doc].should eql(@doc)
    end
  end
  
  describe 'create' do
    before do
      @pmcdoc_id = 'pmcdoc id'
      @div_id = 1
      @section = 'section'
      @text = 'text'
      @project = FactoryGirl.create(:project)
    end  

    context 'when @doc exists' do
      context 'when format html' do
        before do
          post :create, :pmcdoc_id => @pmcdoc_id, :project_id => @project.id, :div_id => @div_id, :section => @section, :text => @text
        end
        
        it 'should redirect to doc_path' do
          response.should redirect_to(doc_path(assigns[:doc]))
        end
      end

      context 'when format json' do
        before do
          post :create, :format => 'json', :pmcdoc_id => @pmcdoc_id, :project_id => @project.id 
        end
        
        it 'should return blank header' do
          response.header.should be_blank
        end
      end
    end

    context 'when @doc does not exists' do
      context 'when format html' do
        before do
          Doc.any_instance.stub(:save).and_return(false)
          post :create, :pmcdoc_id => @pmcdoc_id, :project_id => @project.id, :div_id => 'div', :section => @section, :text => @text
        end

        it 'should redirect to doc_path' do
          response.should render_template('new')
        end
      end

      context 'when format json' do
        before do
          Doc.any_instance.stub(:save).and_return(false)
          post :create, :format => 'json', :pmcdoc_id => @pmcdoc_id, :project_id => @project.id, :div_id => 'div', :section => @section, :text => @text
        end

        it 'should return status 422' do
          response.status.should eql(422) 
        end
      end
    end
  end
  
  describe 'update' do
    before do
      @doc = FactoryGirl.create(:doc)
    end
        
    context 'update sucessfully' do
      context 'when format html' do
        before do
          post :update, :id => @doc.id, :pmcdoc_id => 'id', :doc => {:body => 'new body'}
        end
        
        it 'should redirect to doc_path' do
          response.should redirect_to(doc_path(assigns[:doc]))
        end
      end

      context 'when format json' do
        before do
          post :update, :format => 'json', :id => @doc.id, :pmcdoc_id => 'id', :doc => {:body => 'new body'}
        end
        
        it 'should return blank header' do
          response.header.should be_blank
        end
      end
    end
    
    context 'update unsucessfully' do
      before do
        Doc.any_instance.stub(:update_attributes).and_return(false)
      end
      
      context 'when format html' do
        before do
          post :update, :id => @doc.id, :pmcdoc_id => 'id', :doc => {:body => 'new body'}
        end
        
        it 'should render edit action' do
          response.should render_template('edit')
        end
      end
      
      context 'when format json' do
        before do
          post :update, :format => 'json', :id => @doc.id, :pmcdoc_id => 'id', :doc => {:body => 'new body'}
        end
        
        it 'should return status 422' do
          response.status.should eql(422)
        end
      end
    end
  end
  
  describe 'destroy' do
    before do
      @doc = FactoryGirl.create(:doc)  
    end
    
    context 'format html' do
      before do
        delete :destroy, :pmcdoc_id => 'id', :id => @doc.id
      end
      
      it 'should redirect to docs_url' do
        response.should redirect_to docs_url
      end
    end
    
    context 'format html' do
      before do
        delete :destroy, :format => 'json', :pmcdoc_id => 'id', :id => @doc.id
      end
      
      it 'should return blank header' do
        response.header.should be_blank
      end
    end
  end
end