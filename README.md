# Octosync

Syncs GitHub issues to a RethinkDB and gets real-time updates.

```javascript
var Octosync = require('octosync')
var options = {
	token: 'GITHUB_TOKEN',
	username: 'GITHUB_USERNAME',
	repository: 'GITHUB_REPOSITORY'
};

var o = new Octosync(options);
```

Defaults to connecting to localhost DB on port `28015`.  
Sets up GitHub webhook on port `27070` on path `/octosync`


Available Options

```coffee-script
	db_host: "localhost"
	db_name: "octosync"
	db_port: 28015
	webhook_path: "/octosync"
	webhook_port: 27070
	webhook_secret: "GITHUB_WEBHOOK_SECRET"
	token: "GITHUB_TOKEN"
	username: "GITHUB_USERNAME"
	`repository: "GITHUB_REPOSITORY"
```
