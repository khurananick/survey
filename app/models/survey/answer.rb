class Survey::Answer < ActiveRecord::Base

  self.table_name = "survey_answers"

  acceptable_attributes :attempt, :option, :correct, :option_id, :question, :question_id, :response_text

  # associations
  belongs_to :attempt
  belongs_to :option
  belongs_to :question

  # validations
  validates :question_id, :presence => true
  validates :option_id, :presence => true, :unless => :response_text?
  validates :option_id, :uniqueness => { :scope => [:attempt_id, :question_id] }

  # callbacks
  after_create :characterize_answer

  def value
    points = 0
    option = (self.option.nil? ? Survey::Option.find_by(id:option_id) : self.option)
    points = option.weight if option
    correct?? points : - points
  end

  def correct?
    self.correct ||= self.option.correct? if self.option
  end

  private

  def characterize_answer
    update_attribute(:correct, option.correct?) if option
  end
end
