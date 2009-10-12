Feature: Google Search
  As a developer
  I want to search for information
  In order to learn about Cucumber

Scenario: Searching on Google
  Given I am on the homepage
  When I fill in "q" with "cukes"
  And I press "Google Search"
  Then I should see "cukes.info"

