Feature: Associating an issue to each article
  As a user
  So that I can categorize articles,
  I want to associate an article with an issue

  Scenario: article displays issue
    Given I search for "1600 Pennsylvania Ave NW Washington DC"
    And Jane Doe has a news article with issue "Free Speech"
    When I visit Jane Doe's news articles page
    And I visit the news article
    Then I should see an article with issue "Free Speech"
  
  Scenario: article index displays issues
    Given I search for "1600 Pennsylvania Ave NW Washington DC"
    And Jane Doe has a news article with issue "Free Speech"
    When I visit Jane Doe's news articles page
    Then in the table I should see "Free Speech"
