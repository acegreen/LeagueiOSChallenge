# iOS Coding Challenge

## Overview
The goal of this challenge is to create a basic social media app to showcase your engineering skills.
- API documentation for this challenge can be found [here](#)
- A project is provided to assist in getting started

## Considerations
- You have creative control over the designs, but won't be graded on it
- We use UIKit primarily; however, you're welcome to create your own project or modify any of the provided code
- Well-structured projects and self-documenting code are greatly appreciated
- Embrace the challenge, have fun!

## Requirements

### General
- Do not use any third party libraries for this challenge
- Do not use AI systems during the application process
- Add in unit tests where appropriate
- Add a README to the project with any context you'd like to add (e.g. assumptions, future improvements, architecture followed, etc.)

### Features

#### 1. Login
Create a login page that has the following:
- Username field
- Password field
- "Login" button
- "Continue as guest" button

Logging in or continuing as a guest should take the user to the Post List page.

#### 2. Post List
Create a page that has a list of all available posts.

Each post should display:
- Avatar image
- Username
- Title
- Description

**Logged-in User Features:**
- Navigation button labeled "Logout" that returns to the login page

**Guest User Features:**
- Navigation button labeled "Exit"
- Selecting this button should:
  - Display a "Thank you for trialing this app" message
  - Return to the login page

Tapping on the avatar or username within a post should launch the User Information page modally.

#### 3. User Information
Create a User Information page that contains:
- Avatar image
- Username
- Email Address

**Email Validation:**
- Valid domain extensions: `.com`, `.net`, or `.biz`
- If invalid:
  - Display a warning icon beside the email address

## Acceptance Criteria
This is the criteria that your code will be assessed on:
- The solution runs
- The solution performs all cases correctly
- The code is easy to read
- The code is reasonably documented
- The code is tested (absence of adequate testing leads to disqualification)
- The code is robust and handles invalid input and provides helpful error messages