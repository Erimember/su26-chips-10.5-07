Feature: Accessibility
    So that all users can use our app, and we do not get sued,
    all pages should meet full accessibility standards.

# Accessibility testing relies on a gem called 'axe', which uses JavaScript
# to audit pages for compliance with web standards. See
# https://github.com/dequelabs/axe-core-gems/blob/develop/packages/axe-core-cucumber/README.md
# These tests are excluded by default when running cucumber (see config/cucumber.yml).
# Run cucumber -p a11y to run the 'a11y' profile.

@a11y
Scenario: The Homepage
    Given I am on the homepage
    Then the page should be axe clean

@a11y
Scenario: The Login Page
    Given I am on the login page
    Then the page should be axe clean

@a11y
Scenario: The Representatives Page
    Given I am on the representatives page
    Then the page should be axe clean

@a11y
Scenario: The Events Page
    Given I am on the events page
    Then the page should be axe clean

@a11y
Scenario: The California State Map Page
    Given I am on the state page for "CA"
    Then the page should be axe clean

@a11y @bills
Scenario: The Bills Search Page
    When I visit the bills page
    Then the page should be axe clean

@a11y @bills
Scenario: A Saved Bill Page
    Given a bill has been saved
    When I visit that saved bill's page
    Then the page should be axe clean
