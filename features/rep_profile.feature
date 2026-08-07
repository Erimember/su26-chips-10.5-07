Feature: Visitng representative profile from search
  So that voters can get info on a representative,
  clicking a representative's name should lead to that representative's profile
  
  Scenario: profile page link renders from search
    Given I search for "1600 Pennsylvania Ave NW Washington DC"
    Then I should see a link to Jane Doe's profile page

  Scenario: profile page link renders from news articles
    Given I search for "1600 Pennsylvania Ave NW Washington DC"
    And Jane Doe has a news article
    When I visit Jane Doe's news articles page
    Then I should see a link to Jane Doe's profile page