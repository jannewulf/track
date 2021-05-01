#!/bin/bash

. track

TMP_DIR=
TMP_FILE=

function oneTimeSetUp() {
    TMP_DIR=$(mktemp -d)
    TMP_FILE="$TMP_DIR"/test-track.csv
    printf "
Work,2021-04-30 16:36:35+02:00,2021-04-30 16:36:50+02:00
Thesis,2021-04-30 16:36:56+02:00,2021-04-30 16:37:05+02:00
Work,2021-04-30 16:27:41+02:00,2021-04-30 16:53:08+02:00
Thesis,2021-04-01 10:00:00+02:00,2021-04-01 23:00:00+02:00
Thesis,2021-04-28 01:00:00+02:00,2021-04-28 23:00:00+02:00
" >> "$TMP_FILE"
}

function oneTimeTearDown() {
    rm -rf "$TMP_DIR"
}

function test_timediff() {
    assertEquals -10 $(timediff "@0" "@10")
    assertEquals 10 $(timediff "@10" "@0")
    assertEquals 600 $(timediff "now +10min" "now")
    assertEquals 26340 $(timediff "2021-04-30 16:15:00+02:00" "2021-04-30 08:56:00+02:00")
}

function test_sec_to_hrs_min() {
    assertEquals "0:00" $(sec_to_hrs_min 0)
    assertEquals "0:10" $(sec_to_hrs_min 600)
    assertEquals "1:00" $(sec_to_hrs_min 3600)
    assertEquals "25:00" $(sec_to_hrs_min 90000)
    assertEquals "7:19" $(sec_to_hrs_min 26340)
}

function test_get_project_entries_Work() {
    assertContains "$(get_project_entries Work "$TMP_FILE")" "Work,2021-04-30 16:36:35+02:00,2021-04-30 16:36:50+02:00"
    assertContains "$(get_project_entries Work "$TMP_FILE")" "Work,2021-04-30 16:27:41+02:00,2021-04-30 16:53:08+02:00" 
}

function test_get_project_entries_Thesis() {
    assertContains "$(get_project_entries Thesis "$TMP_FILE")" "Thesis,2021-04-30 16:36:56+02:00,2021-04-30 16:37:05+02:00"
    assertContains "$(get_project_entries Thesis "$TMP_FILE")" "Thesis,2021-04-01 10:00:00+02:00,2021-04-01 23:00:00+02:00" 
    assertContains "$(get_project_entries Thesis "$TMP_FILE")" "Thesis,2021-04-28 01:00:00+02:00,2021-04-28 23:00:00+02:00" 
}

function test_get_start() {
    assertEquals "2021-04-30 16:36:35+02:00" "$(get_start "Thesis,2021-04-30 16:36:35+02:00,2021-04-30 16:36:50+02:00")"
}

function test_get_stop() {
    assertEquals "2021-04-30 16:36:50+02:00" "$(get_stop "Thesis,2021-04-30 16:36:35+02:00,2021-04-30 16:36:50+02:00")"
}

function test_get_stop_or_now_existing() {
    assertEquals "2021-04-30 16:36:50+02:00" "$(get_stop_or_now "Thesis,2021-04-30 16:36:35+02:00,2021-04-30 16:36:50+02:00")"
}

function test_get_stop_or_now_not_existing() {
    assertEquals "$(date --rfc-3339=seconds)" "$(get_stop_or_now "Thesis,2021-04-30 16:36:35+02:00")"
}

function test_start() {
    local start_time="$(date --date='@0' --rfc-3339=seconds)"
    start "Test_start" "$start_time" "$TMP_FILE"
    assertEquals "Test_start,$start_time," "$(grep "^Test_start,$start_time,$" "$TMP_FILE")"
}

function test_stop() {
    local start_time="$(date --date='@0' --rfc-3339=seconds)"
    local stop_time="$(date --date='@600' --rfc-3339=seconds)"
    start "Test_stop" "$start_time" "$TMP_FILE"
    stop "Test_stop" "$stop_time" "$TMP_FILE"
    assertEquals "Test_stop,$start_time,$stop_time" "$(grep "^Test_stop,$start_time,$stop_time$" "$TMP_FILE")"
}

# Load shUnit2.
. ext/shunit2/shunit2
