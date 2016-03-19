class Student < ActiveRecord::Base
  belongs_to :course

  validates :course_id, presence: true
  validates :original_id, presence: true
  validates :learning_resources, presence: true
end