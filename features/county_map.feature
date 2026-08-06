Feature: Finding representatives from the county map
  So that voters can discover who represents a place,
  clicking a county should lead to that district's representatives.

  Scenario: Searching by county name returns the district's legislators
    When I search for "Alameda County, CA"
    Then I should see "Search Results"
    And I should see "Jane Doe"
    And I should see "Richard Roe"

  Scenario: Searching twice does not duplicate representatives
    When I search for "Alameda County, CA"
    And I search for "Alameda County, CA"
    Then there should be 2 representatives

  Scenario: The county page renders for a real county
    When I visit the county page for "CA" county "001"
    Then I should see "County"

  Scenario: An unknown state redirects to the homepage
    Given I am on the state page for "ZZ"
    Then I should see "National Map"

  Scenario: An unknown county redirects to the homepage
    When I visit the county page for "CA" county "999"
    Then I should see "National Map"

  @javascript
  Scenario: The state map renders counties as clickable regions
    Given I am on the state page for "CA"
    Then I should see "California"
    And the map should render clickable regions

  Scenario: A representative's news items page renders
    When I visit a representative's news items page
    Then I should see "News"
