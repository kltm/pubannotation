class Job < ActiveRecord::Base
  belongs_to :project
  belongs_to :delayed_job
  has_many :messages, :dependent => :destroy
  attr_accessible :name, :num_dones, :num_items, :project_id, :delayed_job_id

  scope :waiting, -> {where('begun_at IS NULL')}
  scope :running, -> {where('begun_at IS NOT NULL AND ended_at IS NULL')}
  scope :unfinished, -> {where('ended_at IS NULL')}
  scope :finished, -> {where('ended_at IS NOT NULL')}

  def running?
    !begun_at.nil? && ended_at.nil?
  end

  def finished?
    !ended_at.nil?
  end

  def destroy_if_not_running
    unless running?
      dj = begin
        Delayed::Job.find(self.delayed_job_id)
      rescue
        nil
      end
      dj.delete unless dj.nil?
      update_attribute(:begun_at, Time.now)
      update_related_priority
      self.messages.delete_all
      self.destroy
    end
  end

  def scan
    dj = begin
      Delayed::Job.find(self.delayed_job_id)
    rescue
      nil
    end
    update_attribute(:ended_at, Time.now) if dj.nil?
  end

  def stop_if_running
    if running?
      dj = begin
        Delayed::Job.find(self.delayed_job_id)
      rescue
        nil
      end
      unless dj.nil?
        dj.locked_by.match(/delayed_job.(\d+)/)
        worker_id = $1.to_i
        `script/delayed_job -i #{worker_id} restart`
        update_attribute(:ended_at, Time.now)
      end
    end
  end

  def update_related_priority
    project = begin
      Project.find(project_id)
    rescue
      nil
    end

    if project.present?
      project.jobs.waiting.order(:created_at).each_with_index do |j, i|
        dj = begin
          Delayed::Job.find(j.delayed_job_id)
        rescue
          nil
        end
        dj.update_attribute(:priority, i) unless dj.nil?
      end
    end
  end
end
