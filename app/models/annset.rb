class Annset < ActiveRecord::Base
  attr_accessible :annotator, :description, :name
  has_many :catanns, :dependent => :destroy
  has_many :relanns, :dependent => :destroy
  has_many :insanns, :dependent => :destroy
  has_many :docs, :through => :catanns

  validates :name, :presence => true, :length => {:minimum => 5}
end
