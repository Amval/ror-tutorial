require 'csv'

class Course < ActiveRecord::Base

  belongs_to :user
  has_one :domain, dependent: :destroy
  has_many :students, dependent: :destroy

  default_scope -> { order(created_at: :desc) }
  mount_uploader :concepts, ConceptsUploader
  mount_uploader :activity_log, ActivityLogUploader
  mount_uploader :student_generated_content, StudentGeneratedContentUploader

  validates :user_id, presence: true
  validates :name, presence: true, length: { minimum: 6, maximum: 140}
  validates :concept, presence: true


  #after_save :process_concepts, if: Proc.new { |course| !course.concept.url.nil? }
  after_save :create_domain
  after_save :create_students, if: Proc.new { |course| !course.activity_log.nil? }

  def create_domain
    if !concept.url.nil?
      url = get_absolute_path(concept.url)
      resources = InputReader::learning_resources(url)
      domain_model = Models::DomainModel.new(resources)
      json_domain = ActiveSupport::JSON.encode(domain_model)
      # TODO: Fix! Why does has_one/ self.domain.create not work?
      # It works when the relationships is has_many/ self.domains.create
      Domain.create(course_id: self.id, learning_resources: resources,
        concepts_list: domain_model.node_names, model: json_domain)
    end
  end

  def create_students
    student_data = process_activity_log
    student_data.each do |key, value|
      self.students.create(original_id: key, accessed_learning_resources: value)
    end
  end

  private
    def get_absolute_path(url)
      "#{Dir.pwd}/public#{url}"
    end


    def process_activity_log
      if !activity_log.url.nil?
        url = get_absolute_path(activity_log)
        return InputReader::resources_usage(url)
      end
    end



end
