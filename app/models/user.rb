class User < ApplicationRecord
    has_secure_password

    has_many :events, foreign_key: 'user_id', dependent: :destroy
    has_many :events_registrations, dependent: :destroy
    has_many :joined_events, through: :events_registrations, source: :event

    validates :email, uniqueness: true, presence: true
    validates :name, :mobile_no, :address, :role, presence: true

    def organiser?
        role == 'organiser'
    end

    def user?
        role == 'user'
    end

end
