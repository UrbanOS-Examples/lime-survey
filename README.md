# lime-survey

## Overview

This repository allows us to deploy lime-survey to kubernetes for capturing survey information from users of Smart Columbus inititives.

## Techincal Details

* The RDS for this surveys persistance is stored in the common repository and can be deployed by adding "lime_db" to the enabled features
* This application can be deployed by running the following commands from the repository root
  * `tf init`
  * `tf plan --var=file=variables/{environment}.tfvars --out=out.out`
  * `tf apply out.out`

* This application uses a stateful set which should persist its volumes through helm deletes but there should be no reason to helm delete this app in any non sandbox environment.

## First time configuration
* Lime requires its database schema to be created by running the following commands from the lime pod the very first time the database and pod are deployed (e.g. sandbox deployment)
  * `cd /var/www/html/application/commands`
  * `php console.php install <adminUsername> <adminPassword> <adminDisplayName> <adminEmailAddress>

## Modifying the Theme
* We have themed this application and included the files which are changed in the themes folder here, but these are not continuously integrated or deployed and must be applied to an environment on the first deployment.
* Navigate to the Admin page by adding "admin" to the end of the url for the survey (https://survey.smartcolumbusos.com/)
* Login using the following credentials:
  * Username: admin
  * Password: (Passwords for the web administrator accounts are stored in the secrets manager of the respective environments)
* Navigate to the Theme Editor, make the changes you wish to see in the theme, and save the them before navigating away
* Navigate to "Global Settings" and make sure that the correct theme is selected as the default theme. Save here, and check to make sure your changes have been implemented
