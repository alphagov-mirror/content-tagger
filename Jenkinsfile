#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-content-tagger")
  govuk.buildProject(
    publishingE2ETests: true,
    brakeman: true,
  )
}
