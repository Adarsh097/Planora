class Event < ApplicationRecord
  belongs_to :user  # organiser
  has_many :event_registrations, dependent: :destroy
  has_many :participants, through: :event_registrations, source: :user

  validates :title, :date, presence: true
end
