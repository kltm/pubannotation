require 'spec_helper'

describe Denotation do
  describe 'belongs_to project' do
    before do
      @project = FactoryGirl.create(:project, :user => FactoryGirl.create(:user))
      @denotation = FactoryGirl.create(:denotation, :project => @project, :doc => FactoryGirl.create(:doc))
    end
    
    it 'denotation.should belongs to project' do
      @denotation.project.should eql(@project)
    end
  end
  
  describe 'belongs_to doc' do
    before do
      @doc = FactoryGirl.create(:doc)
      @denotation = FactoryGirl.create(:denotation, :doc => @doc, :project_id => 1)
      @doc.reload
    end
    
    it 'denotation should belongs to doc' do
      @denotation.doc.should eql(@doc)
    end  
    
    it 'doc should count up doc.denotations_count' do
      @doc.denotations_count.should eql(1)
    end  
  end
  
  describe 'has_many subrels' do
    before do
      @denotation = FactoryGirl.create(:denotation, :doc_id => 1, :project_id => 1)
      @relation = FactoryGirl.create(:relation,
        :subj_id => @denotation.id, 
        :subj_type => @denotation.class.to_s,
        :obj_id => 50, 
        :project_id => 1
      )
    end
    
    it 'denotation.resmods should preset' do
      @denotation.subrels.should be_present 
    end
    
    it 'denotation.resmods should include relation' do
      (@denotation.subrels - [@relation]).should be_blank 
    end
  end
  
  describe 'has_many objrels' do
    before do
      @denotation = FactoryGirl.create(:denotation, :doc_id => 1, :project_id => 1)
      @relation = FactoryGirl.create(:relation,
        :subj_id => 1, 
        :subj_type => 'Instance',
        :obj => @denotation, 
        :project_id => 1
      )
    end
    
    it 'denotation.objrels should preset' do
      @denotation.objrels.should be_present 
    end
    
    it 'denotation.resmods should include relation' do
      (@denotation.objrels - [@relation]).should be_blank 
    end
  end
  
  describe 'scope' do
    describe 'within_span' do
      before do
        @denotation_0_9 = FactoryGirl.create(:denotation, :doc_id => 1, :project_id => 1, :begin => 0, :end => 9)
        @denotation_5_15 = FactoryGirl.create(:denotation, :doc_id => 2, :project_id => 2, :begin => 5, :end => 15)
        @denotation_10_15 = FactoryGirl.create(:denotation, :doc_id => 3, :project_id => 3, :begin => 10, :end => 15)
        @denotation_10_19 = FactoryGirl.create(:denotation, :doc_id => 4, :project_id => 4, :begin => 10, :end => 19)
        @denotation_10_20 = FactoryGirl.create(:denotation, :doc_id => 4, :project_id => 4, :begin => 10, :end => 20)
        @denotation_15_19 = FactoryGirl.create(:denotation, :doc_id => 5, :project_id => 5, :begin => 15, :end => 19)
        @denotation_15_25 = FactoryGirl.create(:denotation, :doc_id => 6, :project_id => 6, :begin => 15, :end => 25)
        @denotation_20_30 = FactoryGirl.create(:denotation, :doc_id => 7, :project_id => 7, :begin => 20, :end => 30)
        @denotations = Denotation.within_span({:begin => 10, :end => 20})
      end
      
      it 'should not include begin and end are out of spans' do
        @denotations.should_not include(@denotation_0_9)
      end
      
      it 'should not include begin is out of spans' do
        @denotations.should_not include(@denotation_5_15)
      end
      
      it 'should include begin and end are within of spans' do
        @denotations.should include(@denotation_10_15)
      end
      
      it 'should include begin and end are within of spans' do
        @denotations.should include(@denotation_10_19)
      end
      
      it 'should include begin and end are within of spans' do
        @denotations.should include(@denotation_10_20)
      end
      
      it 'should include begin and end are within of spans' do
        @denotations.should include(@denotation_15_19)
      end
      
      it 'should not include end is within of spans' do
        @denotations.should_not include(@denotation_15_25)
      end
    end
    
    describe 'accessible_projects' do
      before do
        # User
        @current_user = FactoryGirl.create(:user)
        Denotation.stub(:current_user).and_return(@current_user)
        @another_user = FactoryGirl.create(:user)
        # Project
        @current_user_project_1 = FactoryGirl.create(:project, :user => @current_user, :accessibility => 0)
        @current_user_project_2 = FactoryGirl.create(:project, :user => @current_user, :accessibility => 0)
        @another_user_project_1 = FactoryGirl.create(:project, :user => @another_user, :accessibility => 0)
        @another_user_project_accessible = FactoryGirl.create(:project, :user => @another_user, :accessibility => 1)
        # Doc
        @doc_1 = FactoryGirl.create(:doc)
        @doc_2 = FactoryGirl.create(:doc)
        @doc_3 = FactoryGirl.create(:doc)
        @doc_4 = FactoryGirl.create(:doc)
        
        # Denotation
        @current_user_project_denotation_1 = FactoryGirl.create(:denotation, :project => @current_user_project_1, :doc => @doc_1)
        @current_user_project_denotation_2 = FactoryGirl.create(:denotation, :project => @current_user_project_2, :doc => @doc_2)
        @current_user_project_denotation_no_doc = FactoryGirl.create(:denotation, :project => @current_user_project_2, :doc_id => 100000)
        @another_user_project_denotation_1 = FactoryGirl.create(:denotation, :project => @another_user_project_1, :doc => @doc_3)
        @another_user_accessible_project_denotation = FactoryGirl.create(:denotation, :project => @another_user_project_accessible, :doc => @doc_4)
        
        ids = Denotation.all.collect{|d| d.id}
      end
      
      context 'when current_user_id present' do
        before do
          @denotations = Denotation.accessible_projects(@current_user.id)
        end
              
        it "should include denotations belongs to accessibility = 0 and current user's project" do
          @denotations.should include(@current_user_project_denotation_1)
          @denotations.should include(@current_user_project_denotation_2)
        end
        
        it "should not include denotations doc is nil" do
          @denotations.should_not include(@current_user_project_denotation_no_doc)
        end
        
        it "should include denotations belongs to another users's project which accessibility == 1" do
          @denotations.should include(@another_user_accessible_project_denotation)
        end
        
        it "should not include denotations belongs to another users's project which accessibility != 1" do
          @denotations.should_not include(@another_user_project_denotation_1)
        end
      end
      
      context 'when current_user_id present' do
        before do
          @denotations = Denotation.accessible_projects(nil)
        end
              
        it "should include denotations belongs to accessibility = 0 and current user's project" do
          @denotations.should_not include(@current_user_project_denotation_1)
          @denotations.should_not include(@current_user_project_denotation_2)
        end
        
        it "should not include denotations doc is nil" do
          @denotations.should_not include(@current_user_project_denotation_no_doc)
        end
        
        it "should include denotations belongs to another users's project which accessibility == 1" do
          @denotations.should include(@another_user_accessible_project_denotation)
        end
        
        it "should not include denotations belongs to another users's project which accessibility != 1" do
          @denotations.should_not include(@another_user_project_denotation_1)
        end
      end
    end 
    
    describe 'sql' do
      before do
        @denotation_1 = FactoryGirl.create(:denotation, :project_id => 1, :doc_id => 1)
        @denotation_2 = FactoryGirl.create(:denotation, :project_id => 1, :doc_id => 1)
        @denotation_3 = FactoryGirl.create(:denotation, :project_id => 1, :doc_id => 1)
        FactoryGirl.create(:denotation, :project_id => 1, :doc_id => 1)
        @denotations = Denotation.sql([@denotation_1.id, @denotation_2.id])
      end
      
      it 'should include id matched and order by id ASC' do
        @denotations = [@denotation_1, @denotation_2]
      end
    end  
  end
  
  describe 'get_hash' do
    before do
      @denotation = FactoryGirl.create(:denotation,
        :hid => 'hid',
        :begin => 1,
        :end => 5,
        :obj => 'obj',
        :project_id => 'project_id',
        :doc_id => 3
      )
    end
    
    context 'when called' do
      before do
        @get_hash = @denotation.get_hash
      end

      it 'should set hid as id' do
        @get_hash[:id].should eql(@denotation[:hid])
      end
      
      it 'should set begin as denotation:begin' do
        @get_hash[:span][:begin].should eql(@denotation[:begin])
      end
      
      it 'should set end as denotation:end' do
        @get_hash[:span][:end].should eql(@denotation[:end])
      end
      
      it 'should set obj as obj' do
        @get_hash[:obj].should eql(@denotation[:obj])
      end
    end
  end

  describe 'after_save' do
    before do
      @project = FactoryGirl.create(:project, user: FactoryGirl.create(:user))
      @denotation = FactoryGirl.build(:denotation, :project => @project) 
    end

    it 'should exec update_projects_after_save' do
      @denotation.should_receive(:update_projects_after_save)
      @denotation.save
    end

    it 'should exec increment_project_annotations_count' do
      @denotation.should_receive(:increment_project_annotations_count)
      @denotation.save
    end
  end

  describe 'after_destroy' do
    before do
      @project = FactoryGirl.create(:project, user: FactoryGirl.create(:user))
      @denotation = FactoryGirl.create(:denotation, :project => @project) 
    end

    it 'should exec update_projects_after_save' do
      @denotation.should_receive(:decrement_project_annotations_count)
      @denotation.destroy
    end
  end
  
  describe 'update_projects_after_save' do
    before do
      @annotations_updated_at = 10.days.ago
      @project = FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0, :annotations_updated_at => @annotations_updated_at, updated_at: @updated_at)
      @associate_project_1 = FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0)
      @associate_project_2 = FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0)
      @associate_project_2_denotations_count = 1
      @doc = FactoryGirl.create(:doc)
      @associate_project_2.docs << @doc
      @associate_project_2_denotations_count.times do
        FactoryGirl.create(:denotation, :project => @associate_project_2, :doc_id => @doc.id)
      end
      @associate_project_2.reload
      @project.associate_projects << @associate_project_1
      @project.associate_projects << @associate_project_2
      @associate_project_1.reload
      @associate_project_2.reload
      @project.reload
    end
    
    describe 'before create' do
      it 'project.denotations_count should qeual associate_projects' do
        @project.denotations_count.should eql(@associate_project_2_denotations_count * 2)
      end
      
      it 'should not increment associate_project.denotations_count' do
        @associate_project_1.denotations_count.should eql(0)
      end      
      
      it 'should not increment associate_project.denotations_count' do
        @associate_project_2.denotations_count.should eql(1)
      end     
    end     
    
    describe 'after create' do
      before do
        @denotation = FactoryGirl.create(:denotation, :project => @associate_project_2, :doc_id => 1)
        @project.reload
        @associate_project_1.reload
        @associate_project_2.reload
        @project_stub = double('Project') 
        Project.stub(:where).and_return(@project_stub)
      end
          
      it 'should increment project.denotations_count' do
        @project.denotations_count.should eql((@associate_project_2_denotations_count * 2) + 1)
      end      
          
      
      it 'should increment associate_project.denotations_count' do
        @associate_project_1.denotations_count.should eql(0)
      end      
      
      it 'should increment associate_project.denotations_count' do
        @associate_project_2.denotations_count.should eql(2)
      end 
      
      it 'should update project.annotations_updated_at' do
        @project.annotations_updated_at.utc.should_not eql( @annotations_updated_at.utc )
      end     
    end      

    describe 'update project.updated_at' do
      let( :project_stub ) { double('Project')  }
      let( :updated_at ) { 10.days.ago }
      let( :project ) { FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0, updated_at: updated_at) }

      it 'should update project.updated_at' do
        FactoryGirl.create(:denotation, :project => project, :doc_id => 1)
        project.reload
        expect(project.updated_at).not_to eql(updated_at)
      end      
    end
  end

  describe '#increment_project_annotations_count' do
    before do
      @project = FactoryGirl.create(:project, user: FactoryGirl.create(:user))
      @denotation = FactoryGirl.create(:denotation, :project => @project) 
      @project.reload
    end

    it 'should increment project.annotations_count' do
      expect{  
        @denotation.increment_project_annotations_count
        @project.reload
      }.to change{ @project.annotations_count }.from(1).to(2)
    end
  end

  describe 'decrement_project_annotations_count' do
    before do
      @project = FactoryGirl.create(:project, user: FactoryGirl.create(:user))
      @denotation = FactoryGirl.create(:denotation, :project => @project) 
      @project.reload
    end

    it 'should decrement project.annotations_count' do
      expect{  
        @denotation.decrement_project_annotations_count
        @project.reload
      }.to change{ @project.annotations_count }.from(1).to(0)
    end
  end
  
  describe 'update_projects_before_destroy' do
    before do
      @project = FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0)
      @associate_project_1 = FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0)
      @associate_project_2 = FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0)
      @associate_project_2_denotations_count = 1
      @doc = FactoryGirl.create(:doc)
      @associate_project_2.docs << @doc      
      @di = 1
      @associate_project_2_denotations_count.times do
        FactoryGirl.create(:denotation, :project => @associate_project_2, :begin => @di, :doc_id => @doc.id)
        @di += 1
      end
      @associate_project_2.reload
      @denotation = FactoryGirl.create(:denotation, :begin => @di, :project => @associate_project_2, :doc_id => @doc.id)
      @associate_project_1.reload
      @associate_project_2.reload
      @project.associate_projects << @associate_project_1
      @project.associate_projects << @associate_project_2
      @project.reload
    end
    
    describe 'before create' do
      it 'project.denotations_count should equal associate_projects' do
        @project.denotations_count.should eql(@associate_project_2.denotations.count * 2)
      end
      
      it 'should not increment associate_project.denotations_count' do
        @associate_project_1.denotations_count.should eql(0)
      end      
      
      it 'should not increment associate_project.denotations_count' do
        @associate_project_2.denotations_count.should eql(2)
      end     
    end     
    
    describe 'after create' do
      before do
        @denotation.destroy
        @project.reload
        @associate_project_1.reload
        @associate_project_2.reload
      end
          
      it 'should increment project.denotations_count' do
        @project.denotations_count.should eql(@associate_project_2_denotations_count *2 + (1 *2) -1)
      end      
      
      it 'should increment associate_project.denotations_count' do
        @associate_project_1.denotations_count.should eql(0)
      end      
      
      it 'should increment associate_project.denotations_count' do
        @associate_project_2.denotations_count.should eql(1)
      end      
    end      

    describe 'update project.updated_at' do
      let( :project_stub ) { double('Project')  }
      let( :updated_at ) { 10.days.ago }
      let( :project ) { FactoryGirl.create(:project, user: FactoryGirl.create(:user), :denotations_count => 0, updated_at: updated_at) }
      let( :denotation ) { FactoryGirl.create(:denotation, :project => project, :doc_id => 1) }

      it 'should update project.updated_at' do
        denotation.destroy
        project.reload
        expect(project.updated_at).not_to eql(updated_at)
      end      
    end
  end
  
  describe 'self.sql_find' do
    pending do
      before do
      end
      
      context 'when params[:sql] present' do
        before do
          @current_user = FactoryGirl.create(:user)
          @sql = 'select * from denotations;'
          @params = {:sql => @sql}
          @accessible_denotation = FactoryGirl.create(:denotation, :project_id => 1)  
          @project = FactoryGirl.create(:project, :user => FactoryGirl.create(:user))
          @project_denotation = FactoryGirl.create(:denotation, :project => @project)  
          Denotation.stub(:accessible_projects).and_return(Denotation.where(:id => @accessible_denotation.id))
          Denotation.stub(:projects_denotations).and_return(Denotation.where(:id => @project_denotation.id))
        end
        
        context 'when current_user blank' do
          context 'when results.present' do
            context 'when project.present' do
              before do
                @denotations = Denotation.sql_find(@params, nil, @project)
              end
              
              it "should return project's denotations" do
                @denotations.should =~ [@project_denotation]
              end
            end
            
            context 'when project.blank' do
              before do
                @denotations = Denotation.sql_find(@params, nil, nil)
              end
              
              it "should return accessible project's denotations" do
                @denotations.should =~ [@accessible_denotation]
              end
            end
          end
        end
        
        context 'when current_user present' do
          context 'when results.present' do
            context 'when project.present' do
              before do
                @denotations = Denotation.sql_find(@params, @current_user, @project)
              end
              
              it "should return project's denotations" do
                @denotations.should =~ [@project_denotation]
              end
            end
            
            context 'when project.blank' do
              before do
                @denotations = Denotation.sql_find(@params, @current_user, nil)
              end
              
              it "should return accessible project's denotations" do
                @denotations.should =~ [@accessible_denotation]
              end
            end
          end
        end
      end

      context 'when params[:sql] blank' do
        before do
          @denotations = Denotation.sql_find({}, nil, nil)
        end
        
        it 'should return blank' do
          @denotations.should be_blank
        end
      end
    end
  end
end
