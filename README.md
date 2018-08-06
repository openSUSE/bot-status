
# SUSE::BotStatus

  A [Mojolicious](http://mojolicious.org) application for collecting service
  status information via RabbitMQ.

## Workflow

  The process has three components, a client that sends status updates to
  RabbitMQ, a watcher that receives status updates from RabbitMQ, and a web
  application that displays the collected data.

  As bot maintainer you only have to care about the client-side. To update their
  status, your bots will have to connect to RabbitMQ and send a small JSON
  object in regular intervals. For Perl and Python you can just reuse the
  already prepared code samples in the `examples` directory.

  If your bot is unable to connect to RabbitMQ directly, you can also use the
  program `tools/update_bot_status` to update its status. The program can be
  copied independently of the rest of this repository and only requires the
  `Mojo::RabbitMQ::Client` Perl module to be installed (available in the package
  `perl-Mojo-RabbitMQ-Client`).

  You will need an account and password for RabbitMQ access however, which you
  can request from `coolo at suse dot de`.

## Status Protocol

  The status update protocol is stateless. Updates are published as JSON objects
  through a RabbitMQ topic exchange named `pubsub`, with the routing key
  `suse.bot.status`. It is up to the consumer to infer meaning to status
  updates, but usually only the latest update will be considered the current
  status of a service.

    {"name":"legal-auto-suse","status":"ok",comment:"Processing 145 packages"}

### Required values

Only two values are currently required.

  * `name`: The name of the service. An arbitrary string that should be unique.
  * `status`: The current status of the service. Only these four values are
    allowed.
    * `ok`: The service is functioning fine.
    * `warning`: The service might be experiencing problems soon. (High
       memory/cpu usage, growing backlog...)
    * `failed`: The service is experiencing problems and needs attention.
    * `gone`: The service is no longer operational and should not be monitored
      anymore.

### Optional values

  These values can be included to provide additional information to human
  observers.

  * `comment`: A short sentence describing the current status. (Something like
    *Checking "obs#626034" for errors* or *Backlog is growing too fast*)
  * `meta`: A JSON object with arbitrary key/value pairs, containing additional
    information you would like to share but that are not part of the main status
    update protocol yet.

### Examples

Minimal status update signaling that everything is fine.

    {"name":"xcdchk","status":"ok"}

Warning with short description.

    {"name":"openqa-worker-3","status":"warning","comment":"High memory usage"}

Failure with additional meta data.

    {"name":"rpmlint","status":"failed","meta":{"contact":"coolo@suse.de"}}

Stop monitoring an obsolete service.

    {"name":"licensedigger","status":"gone"}
