# == Schema Information
#
# Table name: analyses
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  transcript      :text
#  context         :text
#  summary         :text
#  key_points      :text
#  interview_review :text
#  feedback        :text
#  action_items    :text
#  sentiment       :text
#  language        :string
#  style           :string
#  agent_provider  :string
#  status          :string           default("pending")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Analysis model stores meeting transcript analysis results.
# Uses async job processing to analyze transcripts with AI agents.
#
class Analysis < ApplicationRecord
  belongs_to :user

  serialize :key_points, coder: YAML
  serialize :interview_review, coder: YAML
  serialize :feedback, coder: YAML
  serialize :action_items, coder: YAML
  serialize :sentiment, coder: YAML

  # Status constants
  STATUS_PENDING = "pending"
  STATUS_PROCESSING = "processing"
  STATUS_COMPLETED = "completed"
  STATUS_FAILED = "failed"

  # Validations
  validates :transcript, presence: true
  validates :language, inclusion: { in: %w[en es fr de pt] }, allow_nil: true
  validates :style, inclusion: { in: %w[concise detailed] }, allow_nil: true
  validates :agent_provider, inclusion: { in: %w[ollama openai anthropic] }, allow_nil: true
  validates :status, inclusion: { in: [ STATUS_PENDING, STATUS_PROCESSING, STATUS_COMPLETED, STATUS_FAILED ] }, allow_nil: true

  # Scopes
  scope :completed, -> { where(status: STATUS_COMPLETED) }
  scope :processing, -> { where(status: STATUS_PROCESSING) }
  scope :pending, -> { where(status: STATUS_PENDING) }
  scope :failed, -> { where(status: STATUS_FAILED) }

  # Check if analysis is completed
  def completed?
    status == STATUS_COMPLETED
  end

  # Check if analysis is processing
  def processing?
    status == STATUS_PROCESSING
  end

  # Check if analysis failed
  def failed?
    status == STATUS_FAILED
  end

  # Store structured data from AI analysis
  # @param result [Hash] Analysis result from AI agent
  def store_analysis_result(result)
    self.summary = result[:summary]
    # Ensure arrays and hashes are properly serialized
    self.key_points = Array(result[:key_points] || [])
    self.interview_review = result[:interview_review] || {}
    self.feedback = Array(result[:feedback] || [])
    self.action_items = Array(result[:action_items] || [])
    self.sentiment = result[:sentiment] || {}
    save!
  end
end
