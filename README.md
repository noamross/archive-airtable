# airtable-archive

Workflow to archive an AirTable base as CSVs in a git repository, as well as 
downloading any files attached to tables. Uses `phantomjs` to
collecti informaation about the base schema in order to download all tables.

The following environement variables are needed:

- `DATA_REPO_URL` - The remote git repo you want to store data in.  If using GitHub, something like `https://USER:GITHUB_PAT@github.com/user/repo` will make it easy to automate the script, but it's not super secure.  Otherwise credentials should be set by using an SSH git URL and and local keys
- `AT_BASE` - The AirTable base to pull from.  This is of the form `appXXXXXXXXXX`, and is found in the URL of the API of your AirTable, e.g., `https://airtable.com/appXXXXXXXXXX/api/docs`.
- `AIRTABLE_LOGIN_EMAIL` - Your user account email = Sys.getenv("AIRTABLE_LOGIN_EMAIL") #airtable creds.  Note that AIRTABLE_API_KEY is also needed in the environment
-  `AIRTABLE_LOGIN_PWD` - Your Airtable user account password
-  `AIRTABLE_API_KEY` - Your AirTable API key.
-  `GIT_USER` - The git user name to sign automated commits with
-  `GIT_EMAIL` - The git user email to sign automated commits with
