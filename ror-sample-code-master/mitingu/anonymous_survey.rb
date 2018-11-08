class AnonymousSurvey < ActiveRecord::Base
  belongs_to :event

  validate :survey_answers_valid, on: :create

  attr_accessor :page

  def pages
    event.questions.for_survey.select {|el|el.break_page?}.count + 1
  end
  #generation questions
  def questions
    return [] if page.blank?
    i=1
    groups = {}
    event.questions.for_survey.each do |q|
      if q.break_page?
        i=i+1
        next
      end
      groups[i] = [] if groups[i].blank?
      groups[i] << q
    end
    groups[page.to_i]
  end
  #show answers
  def survey_answers_valid
    return unless survey_answers_changed?
    questions.each do |question|
      if question.required? && (question.ignore_tags? || tagged_for_rule(question.tag_rule, question.tags))
        if question.show_on_question && question.show_on_answer
          next unless survey_answers && survey_answers[question.show_on_question.field] == question.show_on_answer.value
        end
        errors.add :base, I18n.t("errors.messages.no_answer_to_question", question: question.title) unless survey_answers && survey_answers[question.field].present?
      end
    end
  end

  def merge_survey_fields
    self.survey_answers || {}
  end

  def merge_survey_fields=(value)
    parameterized_value = {}
    value.delete_if { |k, v| v.blank? } 
    value.each do |k,v|
      if v.is_a?(Array)
        parameterized_value[k.parameterize] = v.reject{ |el| el.blank? }.join(",")
      else
        parameterized_value[k.parameterize] = v.is_a?(String) ? v.strip : v
      end
    end
    self.survey_answers = (self.survey_answers || {}).merge(parameterized_value)
  end

end
