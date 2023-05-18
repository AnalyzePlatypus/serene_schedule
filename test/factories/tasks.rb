FactoryBot.define do
  factory :task do
    association :project
    title { "MyString" }
    notes { "MyString" }
    estimated_hours { 1.5 }
    actual_hours { 1.5 }
    priority { 1 }
  end
end
