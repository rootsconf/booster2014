class Talk < ActiveRecord::Base
  default_scope :order => 'talks.created_at desc'

  has_many :speakers
  has_many :users, :through => :speakers
  has_many :slots
  has_many :periods, :through => :slots
  has_many :comments, :order => "created_at", :include => :user
  has_and_belongs_to_many :tags
  has_many :feedback_comments
  belongs_to :talk_type
  has_many :participants, :include => :user, :dependent => :destroy

  #has_attached_file :slide, PAPERCLIP_CONFIG

  #validates_attachment_content_type :slide, :content_type => ['application/pdf', 'application/vnd.ms-powerpoint', 'application/ms-powerpoint', %r{application/vnd.openxmlformats-officedocument}, %r{application/vnd.oasis.opendocument}, 'application/zip', 'application/x-7z-compressed', 'application/x-gtar']

  #validates_attachment_size :slide, :less_than => 50.megabytes

  validates_acceptance_of :accepted_guidelines
  validates_acceptance_of :accepted_cc_license
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :language

  attr_accessible :talk_type, :talk_type_id, :language, :title, :description, :audience_level, :max_participants,
                  :participant_requirements, :equipment, :room_setup, :accepted_guidelines, :acceptance_status

  def after_initialize
    self.acceptance_status||= "pending"
  end

  def speaker_name
    users.map(&:name).join(", ")
  end

  def speaker_invited
    users.any?(&:invited)
  end


  def speaker_email
    users.map(&:email).join(", ")
  end

  def option_text
    %Q[#{id} - "#{trunc(title, 30)}" (#{trunc(speaker_name, 20)})]
  end

  def trunc(text, length)
    (text.length < length + 3) ? text : "#{text.first(length)}..."
  end

  def describe_audience_level
    case audience_level
      when 'novice' then
        'Novice'
      when 'intermediate' then
        'Intermediate'
      when 'expert' then
        'Expert'
      else
        ''
    end
  end

  def license
    "by"
  end

  def email_is_sent?
    email_sent
  end


  def accept!
    self.acceptance_status = "accepted"
    self
  end

  def accepted?
    self.acceptance_status == "accepted"
  end

  def pending?
    self.acceptance_status == "pending"
  end

  def refused?
    self.acceptance_status == "refused"
  end

  def refuse!
    self.acceptance_status = "refused"
    self
  end

  def regret!
    self.acceptance_status = "pending"
    self
  end

  def is_lightning_talk?
    # TODO: Megahack!
    talk_type.name == 'Lightning talk'
  end

  def is_tutorial?
    !is_lightning_talk?
  end

  def is_full?
    participants.size >= max_participants
  end

  def update_speakers(current_user)
    for speaker in self.users
      speaker.update_ticket_type(current_user)
    end
  end

  def average_feedback_score
    score = self.sum_of_votes.to_f / self.num_of_votes.to_f
    "%.2f" % score
  end

  def is_in_one_of_these(periods)
    self.periods.each { |period|
      if periods.include? period
        return true
      end
    }
    false
  end

  def start_time
    periods.sort! { |first, second| first.start_time <=> second.start_time }.first.start_time
  end

  def end_time
    periods.sort! { |first, second| first.end_time <=> second.end_time }.last.end_time
  end

  def is_scheduled?
    periods.present? && periods.length > 0
  end

  def self.all_pending_and_approved
    all(:order => 'acceptance_status, id desc', :include => {:users => :registration}).select {
        |t| !t.refused? && !t.users.first.nil? && t.users.first.registration.ticket_type_old == "speaker"
    }
  end

  def self.all_pending_and_approved_tag(tag)
    talks_tmp = all(:order => 'acceptance_status, id desc', :include => {:users => :registration}).select {
        |t| !t.users.first.nil? && t.users.first.registration.ticket_type_old == "speaker"
    }
    talks = []
    talks_tmp.each do |talk|
      if talk.tags.include? tag
        talks.push talk
      end
    end
    talks
  end

  def self.all_accepted
    all(:include => :slots, :conditions => "acceptance_status = 'accepted'")
  end

  def self.all_accepted_tutorials
    all(:include => [:talk_type, :slots, :periods], :conditions => ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 't'"], :order => "title ")
  end

  def self.all_accepted_lightning_talks
    all(:include => :talk_type, :conditions => ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 'f'"], :order => "title ")
  end

  def self.all_with_speakers
    with_exclusive_scope { find(:all, :include => :users, :order => "users.name ") }
  end

  def self.add_feedback(talk_id, sum, num)
    talk = Talk.find(talk_id, :include => :users)
    talk.sum_of_votes = sum
    talk.num_of_votes = num

    talk.save
  end

  def self.add_comment(talk_id, comment)
    comm = FeedbackComment.new
    comm.comment = comment
    comm.talk = Talk.find(talk_id)
    comm.save!
  end

  def self.count_accepted
    self.count(:conditions => "acceptance_status = 'accepted'")
  end

  def self.count_refused
    self.count(:conditions => "acceptance_status = 'refused'")
  end

  def self.count_pending
    self.count(:conditions => "acceptance_status = 'pending'")
  end

  def to_s
    "\"#{self.title}\" by #{self.speaker_name}"
  end

  def self.find_all_with_ids(id_array)
    self.find(:all, :conditions => {:id => id_array})
  end

end