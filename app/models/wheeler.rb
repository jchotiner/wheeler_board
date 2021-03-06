class Wheeler < ActiveRecord::Base
  include ActionView::Helpers

  attr_accessible :profile_id, :lgtm_employee_id, :description, :reporter_id

  belongs_to :profile
  belongs_to :lgtm_employee, class_name: 'Profile'
  belongs_to :reporter, class_name: 'Profile'

  after_create :recalculate_uptime
  after_create :notify_campfire
  after_save :recalculate_uptime

  validates :profile, presence: true
  validates :reporter, presence: true
  validates :description, presence: true, length: { maximum: 140 }

  paginates_per 5

  def prev_wheeler
    Wheeler.where('created_at < ?', created_at).order('created_at desc').first
  end

  def uptime_in_words
    time_ago_in_words DateTime.now - uptime.seconds if uptime
  end

  def recalculate_uptime
    if prev_wheeler
      update_column :uptime, (created_at - prev_wheeler.created_at).to_i
      prev_wheeler.recalculate_uptime
    else
      update_column :uptime, 0
    end
  end

  def to_s
    str = "#{profile} broke Tapjoy #{time_ago_in_words(created_at)} ago."
    str += " \"#{description}\" Reported by #{reporter}"
    str += " lgtm'ed by #{lgtm_employee}." if lgtm_employee
  end

  private

  def notify_campfire
    notification = "WheelerBoard: http://wheeler-board.tapjoy.net #{self}"
    Rails.logger.info notification
    CAMPFIRE.speak notification if Rails.env.production?
  end

end
