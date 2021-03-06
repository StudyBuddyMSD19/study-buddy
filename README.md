# Study Buddy

*Flutter web app - PWA - single-page application (SPA) - Firebase backend*

## Contents

+ [Features](#features)
+ [Dependencies](#dependencies)
+ [Debug and Test](#debug-and-test)
+ [Build](#build)
+ [Deploy to Firebase](#deploy-to-firebase)
+ [Known Issues](#known-issues)

## Features

#### Tasks

- [x] create, edit, delete tasks
- [x] receive points upon task completion

#### Groups

- [ ] join groups
- [ ] leave groups

#### Scoreboard

- [x] list users according to score

#### Feed

- [x] review completed tasks

## Dependencies

`npm install -g firebase-tools`

## Debug and Test

`firebase serve` or

`flutter run -d web-server --web-port 5000`

-> go to `http://localhost:5000`

## Build

`flutter build web --release --web-renderer html`

## Deploy to Firebase

### Preview

`firebase hosting:channel:deploy preview`

### Production

`firebase deploy`

## Known Issues

TBA
