# track - Time tracking
track is a simple tool to track times for projects. 
It makes it easy to track the times you are working on a project.

## Usage
The times you insert are passed to `date`, i.e. values like `now`, `now -10 min` and `yesterday 08:13` can be used.

### Start timer
```
$ track start PROJECT [START_TIME] [STOP_TIME]
```
`START_TIME` defaults to `now`.

`STOP_TIME` can be left blank. Then the timer stays active.

### Stop timer
```
$ track stop PROJECT [STOP_TIME]
```
`STOP_TIME` defaults to `now`.

### Status
```
$ track status PROJECT
```

## Running tests
Simply run 
```
$ ./test.sh
```