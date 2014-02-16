[![Build Status](https://secure.travis-ci.org/joakimk/deployer.png)](http://travis-ci.org/joakimk/deployer)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/joakimk/deployer)

## About

This is a tool for viewing CI build status from multiple CI servers and projects. It is based on the internal tools we have been using at [barsoom](http://barsoom.se).

It can be deployed to heroku but there are no instructions yet.

The tool used to report build status isn't part of this repo yet.

## How it looks

![how it looks](http://cl.ly/image/3t021A0n2d25/Screen%20Shot%202014-02-16%20at%201.10.25%20PM.png)

The names links to the `status_url` passed in when reporting builds. At barsoom we pass in a link to the jenkins build result console. This way we can easily get to any build result of any recent revision.

## Work in progress

Right now it can show build status, link to build results and github.

One thing I'd like to do it to make it manage continous deployment pipelines better than what I can do with jenkins plugins.

## Running the tests

You need postgres installed.

    script/bootstrap

    rake              # all tests
    rake spec:unit    # unit tests
    rake spec         # integrated tests

## Download production data

    rake app:reset
