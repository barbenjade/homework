defmodule HomeworkTest do
  # Import helpers
  use Hound.Helpers
  use ExUnit.Case

  # Start hound session and destroy when tests are run
  hound_session()

  #Method to validate login page (check flash message for str argument values)
  def flash_msg_validation(txt, str) do
    if is_binary(str) and String.contains?(txt, str) do
      True
    else
      False
    end
  end

  #This method takes a dynamic number of items with a certain tag and performs actions on pop up modals
  def click_buttons(t) do
    listone = find_all_elements(:tag, t)
    number_of = Enum.count(listone)
    Enum.each listone, fn x ->
        iter = to_string(x)
        iter2 = String.at(iter, -1)
        if iter2 == number_of do
          click({:xpath, "//li[#{iter2}]/#{t}"})
          input_into_prompt("First Test for prompt")
          accept_dialog()
        else
          click({:xpath, "//li[#{iter2}]/#{t}"})
          accept_dialog()
        end
    end
  end

  @moduletag timeout: 200000

  test "navigates to heroku app, tests dropdown functionality" do
    assert_one = []
    navigate_to "https://the-internet.herokuapp.com/dropdown"
    #Confirm element is present on page, if so test it
    if element_displayed?({:id, "dropdown"}) do
      click({:id, "dropdown"})
      click({:xpath, "//div/select/option[contains(text(), '1')]"})
      if selected?({:xpath, "//div/select/option[contains(text(), '1')]"}) do
        click({:xpath, "//div/select/option[contains(text(), '2')]"})
      else
        assert_one = List.insert_at(assert_one, -1, "Option 1 was not clicked as dictated")
      end
    else
      assert_one = List.insert_at(assert_one, -1, "No Dropdown Displayed as Expected")
    end
    #Test to confirm element size is not too large
    element = find_element(:id, "content")
    element_size = element_size(element)
    if element_size > 3, do: "element size above 3", else: IO.puts "Element size below 3"
    #Alert user if there were errors in the test or if they passed
    if Enum.count(assert_one) > 0, do: IO.puts "Errors: Assert One - #{assert_one}", else: IO.puts "Dropdown tests passed"
  end

  test "navigates to login test page to validate user credentials" do
    assert_two = []
    #List and Enum functions to manipulate password for test cases (inefficient in order to showcase Elixir)
    user_name = "tomsmith"
    psswrd = "super secret password!"
    err = "Login defect: Error message not displayed"
    psswrd_list = String.split(psswrd, " ")
    new_list = Enum.map(psswrd_list, fn(n) -> String.capitalize(n) end)
    real_psswrd = Enum.join(new_list, "")
    rand_int = Enum.random(3..6)
    psswrd_len = String.length(real_psswrd)

    navigate_to "https://the-internet.herokuapp.com/login"
    #Test case: Confirm no login allowed with Invalid credentials
    fill_field({:id, "username"}, "Incorrect Name Test")
    fill_field({:id, "password"}, "IncorrectPasswordTest")
    submit_element({:id, "password"})
    flash_text = find_element(:id, "flash")
    text = visible_text(flash_text)
    unless flash_msg_validation(text, 'invalid') do
      assert_two = List.insert_at(assert_two, -1, err)
    end
    #Test case: Similar password but not complete/correct
    fill_field({:id, "username"}, user_name)
    fill_field({:id, "password"}, String.slice(real_psswrd, rand_int, psswrd_len))
    submit_element({:id, "password"})
    unless flash_msg_validation(text, 'invalid') do
      assert_two = List.insert_at(assert_two, -1, err)
    end
    #Test Case: Confirm correct username required for successful login.
    fill_field({:id, "username"}, "tomsmth")
    fill_field({:id, "password"}, real_psswrd)
    unless flash_msg_validation(text, 'invalid') do
      assert_two = List.insert_at(assert_two, -1, err)
    end
    #Test case: Confirm correct username and password logs user in correctly.
    fill_field({:id, "username"}, user_name)
    fill_field({:id, "password"}, real_psswrd)
    submit_element({:id, "password"})
    unless element_displayed?({:xpath, "//a/i[@class='icon-2x icon-signout']"}) do
      assert_two = List.insert_at(assert_two, -1, "Login was not successful with correct credentials.")
    end
    if current_url() == "https://the-internet.herokuapp.com/secure" do
      IO.puts "Sign in successful - login navigated user to correct page"
    end
    #Confirm correct behavior for logout functionality
    click({:xpath, "//a/i[@class='icon-2x icon-signout']"})
    flash_text2 = find_element(:id, "flash")
    text2 = visible_text(flash_text2)
    unless flash_msg_validation(text2, 'You logged out') do
      assert_two = List.insert_at(assert_two, -1, "Logout defect: Error when logging out")
      # message(err)
    end
    #Alert user if there were errors in the test or if they passed
    if Enum.count(assert_two) > 0, do: IO.puts "Errors: Assert Two - #{assert_two}", else: IO.puts "Login tests passed"
  end

  test "navigates to JavaScript Alerts page and tests buttons and dialog functions using tag name" do
    assert_three = []
    navigate_to "https://the-internet.herokuapp.com/javascript_alerts"
    tag = tag_name({:xpath, "//div[@class='example']/ul/li/button[contains(text(), 'Alert')]"})
    click_buttons(tag)
    console_logs = fetch_log()
    if String.length(console_logs) == 0 do
      IO.puts console_logs
    else
      IO.puts "No Log Errors for tag test"
    end
    if Enum.count(assert_three) > 0, do: IO.puts "Errors: Assert Three - #{assert_three}", else: IO.puts "Alerts tests passed"
  end

  test "takes screen shot of JavaScript error page"  do
    navigate_to "https://the-internet.herokuapp.com"
    click({:xpath, "//div[@id='content']/ul/li[30]"})
    #Test to confirm browser navigation ability with a JS error.
    navigate_to "https://the-internet.herokuapp.com"
    click({:xpath, "//div[@id='content']/ul/li[30]"})
    take_screenshot("../img")
    msg2 = "No Log Errors for JS screen shot"
    console_logged = fetch_log()
    if String.length(console_logged) == 0, do: IO.puts console_logged, else: IO.puts msg2
  end
end
