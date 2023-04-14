# Smart Throttler: Request limiting for Preside Applications

This extension allows you to add finer control of request throttling for your Preside applications:

1. Limit the max number of requests Preside will process
2. Set a maximum queue size for requests over the limit
3. Define URL paths that will *bypass the queue* - i.e. healthchecks
4. Define URL paths that should be treated as a priority
5. Define whether or not to prioritise logged in users (web and admin)

The project is currently in an ALPHA state.

## Configuration

Configuration of the extension can provided either through environment variables, or by direct settings in your application's Config.cfc. Variables to set:

* `maxActiveRequests`: Maximum number of active requests before queueing requests. Default is `0` which turns off all functionality of this extension
* `queueSize`: The maximum number of queued requests. Default is `0`.
* `queueTimeout`: The maximum time in seconds that a request can be in the queue before timing out. Default is `50`.
* `failureStatusCode`: Status code to use when either the queue is full, or requests timeout. Default is `503`.
* `sleepInterval`: How long queued threads sleep for before checking their status again (in ms). Default is `50`.
* `skipPaths`: An array of URL paths that can bypass the queue entirely. These are matched with a "startsWith" pattern so an incoming `/api/v2/events/` request matches an `/api/` path
* `priorityPaths`: An array of URL paths that will be placed in the priority queue and processed before "standard" requests. These are matched with a "startsWith" pattern so an incoming `/api/v2/events/` request matches an `/api/` path
* `prioritiseUsers`: Boolean, whether or not to put logged in user requests into the priority queue. Default is `true`.
* `prioritiseAdmins`: Boolean, whether or not to put logged in admin user requests into the priority queue. Default is `false`.

### Using environment variables

The following environment variables can be set to control the configuration options, above:

* `SMARTTHROTTLER_MAX_ACTIVE_REQUESTS`
* `SMARTTHROTTLER_QUEUE_SIZE`
* `SMARTTHROTTLER_QUEUE_TIMEOUT`
* `SMARTTHROTTLER_FAILURE_STATUS_CODE`
* `SMARTTHROTTLER_SLEEP_INTERVAL`
* `SMARTTHROTTLER_SKIP_PATHS` (use a string list of paths, e.g. "/alive,/metrics")
* `SMARTTHROTTLER_PRIORITY_PATHS` (use a string list of paths, e.g. "/api,/login")
* `SMARTTHROTTLER_PRIORITISE_USERS`
* `SMARTTHROTTLER_PRIORITISE_ADMINS`

See [Configuring Preside](https://docs.preside.org/devguides/config.html#injecting-environment-variables) page in Preside docs for a guide to injecting environment variables.

### Using Config.cfc

```cfc
settings.smartThrottler.maxActiveRequests = 20;
settings.smartThrottler.queueSize         = 100;
settings.smartThrottler.queueTimeout      = 50;
settings.smartThrottler.failureStatusCode = 503;
settings.smartThrottler.sleepInterval     = 20;
settings.smartThrottler.skipPaths         = [ "/alive", "/metrics" ]; // must be an array
settings.smartThrottler.priorityPaths     = [ "/login/", "/admin/" ]; // must be an array
settings.smartThrottler.prioritiseUsers   = true;
settings.smartThrottler.prioritiseAdmins  = false;
```

## Versioning

We use [SemVer](https://semver.org) for versioning. For the versions available, see the [tags on this repository](https://github.com/pixl8/preside-ext-smart-throttler/releases). Project releases can also be found and installed from [Forgebox](https://forgebox.io/view/preside-ext-smart-throttler)

## License

This project is licensed under the GPLv2 License - see the [LICENSE.txt](https://github.com/pixl8/preside-ext-smart-throttler/blob/stable/LICENSE.txt) file for details.

## Authors

The project is maintained by [The Pixl8 Group](https://www.pixl8.co.uk). The lead developer is [Dominic Watson](https://github.com/DominicWatson) and the project is supported by the community ([view contributors](https://github.com/pixl8/preside-ext-smart-throttler/graphs/contributors)).

## Code of conduct

We are a small, friendly and professional community. For the eradication of doubt, we publish a simple [code of conduct](https://github.com/pixl8/preside-ext-smart-throttler/blob/stable/CODE_OF_CONDUCT.md) and expect all contributors, users and passers-by to observe it.