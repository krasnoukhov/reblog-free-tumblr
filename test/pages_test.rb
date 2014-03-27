require File.expand_path("helper", File.dirname(__FILE__))

scope do
  test "Home" do
    visit "/"
    assert has_content?("Tired of endless reblogs?")
  end

  test "Username" do
    visit "/reblogs-free.rss"
    assert has_content?("Hey yo! This is not a reblog.")
    assert !has_content?("Drawing as a programmer")
  end
end
