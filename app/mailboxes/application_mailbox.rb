class ApplicationMailbox < ActionMailbox::Base
  routing(/goal-[a-zA-Z0-9_\-]+@/i => :goal_responses)
end
