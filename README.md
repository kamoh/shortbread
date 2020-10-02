
# Shortbread

## Intro
====

A delicious URL shortener. See it live at http://shrtb.red.

Setup

Shortbread is made with Ruby on Rails.

Install rails:

``` ruby
sudo gem install rails
```

Set up your gems:

``` ruby
bundle install
```

Set up the database:

``` ruby
rake db:migrate
```

This app uses Postgres for the database.

You'll need a domain to point shortened links to. In link.rb, replace `URL_BASE = "shrtb.red/"` with whatever domain you want to serve shortened URLs from.

Shortened URLs are case-sensitive, so bear that in mind.

The site tracks the top 100 most visited links. You can adjust this in the constant `MOST_VISITED_LIMIT` in link.rb.

Test Suite

This app uses Rspec. To run tests on the Link model, simply type:

``` ruby
rspec
```

## Creating the Containers

Tools:
 - [packer](https://www.packer.io/)
 - [docker](https://www.packer.io/)
 

```sh
###
# Build docker container and tag as `shrtbred`
###
docker build . -t shrtbred

###
# Build shortbred app container
###
packer build ./packer-shortbread.json

###
# Build shortbred nginx asset container
###
packer build ./packer-nginx-assets.json

```

## Configuration

### Shrtbred Container

Environment Variables

Name | Description | Default
---- | ----------- | -------
SECRET_KEY_BASE | The key to use when encoding the cookie | `N/A`
SHRTBRED_DATABASE_NAME | The name of the postgres database | `shrtbred`
SHRTBRED_DATABASE_USER | The username to use when connecting to the database | `shrtbred`
SHRTBRED_DATABASE_PASSWORD | The password to use when connecting to the database | `shrtbred`
SHRTBRED_DATABASE_HOST | The host of the database server  | `shrtbred`
SHRTBRED_DATABASE_PORT | The port of the database server   | `5432`
SHRTBRED_PORT | The port to have the rails server listen on | `3000`
SHRTBRED_SEED_DATA | This will populate the database you are connected to with seed data | false
RAILS_ENV | The rails environment to use. Example: development, test, production | `production`
URL_BASE | the url to use when generating links | `localhost:3000`


### Shrtbred Asset Container

| Used to serve static assets whenever they are available. If no asset is found send the request to the application server

Environment Variables

Name | Description | Default
---- | ----------- | -------
GENERATE_SSL_CERT | If set to true it will generate a self signed certificate | `false`
LISTEN_PORT | The port for nginx to listen on | `3000`
SHRTBRED_HOST | The hostname of the shrtbred app server | `shrtbred`
SHRTBRED_PORT | The port that the shrtbred app server is listening on | `3100`


## Database Server

If leveraging k8s I would use or create a helm chart that allows for a HA cluster to serve the requests. Bitnami has created a solid starting point with the [chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql-ha).

recommendations:
```
## Enable netowrk policy to prevent any access from outside of k8s from accessing the cluster
networkPolicy.enabled: true
networkPolicy.allowExternal: false
## Metrics for monitoring
metrics.enabled: true
pgpool.configuration: |
   
```


## Questions

### Metrics

- Tools
  - Prometheus
    - I would use it to scrape the metrics using annotations on the relevant k8s components that need to be monitored
  - AlertManager
    - Alerting for relevant conditions
  - Grafana
    - Visualization of the scraped metrics
- Setup
  - Prometheus Operator with Thanos
  - Details:
    - Use service monitor CRD to select the various metric endpoints that need to be
    - Prometheus would use persistent volume claims to store recent metrics
    - Use thanos to ship historical metrics to cloud storage



### Subnets
- 192.168.200.0/26
- 192.168.200.64/26
- 192.168.200.128/26
- 192.168.200.192/26

### Log Parsing

When using the rails env: `alpha` use the below fluentd configuration to parse and send to the relevant log service:
```
<source>
  @type tail
  path ./log/alpha.log
  pos_file ./tmp/alpha-log.pos
  tag shrtbred.alpha
  <parse>
    @type multiline
    format_firstline /Started.*(?<time>[0-9]{4}-[0-9]{1,2}-[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} -[0-9]{4})/
    format1 /(?<log>[\s\S]*)/
  </parse>
</source>
##
# Adding fluentd_worker label in case you are using multiple workers
##
<filter shrtbred.alpha>
    @type record_modifier
    <record>
        fluentd_worker "#{worker_id}"
    </record>
</filter>
##
# Example of parsing for relevant values. We don't want to lose the entire log message so reserve_data is set to true.
##
<filter shrtbred.alpha>
  @type parser
  key_name log
  reserve_data true
  <parse>
    @type regexp
    expression /Completed (?<completion_code>[0-9]{3}) (?<completion_status>[A-Z]{1,}) [a-z]{1,} (?<response_time>[0-9]{1,}[A-Za-z]{1,})/
  </parse>
</filter>
##
# In this example we are using loki as our target. Adding the named capture groups we want to use as labels to the output to loki.
##
<match shrtbred.alpha>
  @type loki
  url "http://loki-alpha.shrtbred.com"
  username "#{ENV['LOKI_USERNAME']}"
  password "#{ENV['LOKI_PASSWORD']}"
  extra_labels {"env":"alpha"}
  flush_interval 10s
  flush_at_shutdown true
  buffer_chunk_limit 1m
   <label>
    completion_code
    completion_status
    response_time
    fluentd_worker
  </label>
</match>
```

### 5AM Cron Job

#### Cron Expression 

```
0 5 * * *
```

#### One Liner
```sh
cat ./tmp/nginx/shrtbred/nginx.access.log | grep -c "$(date +"%d/%b/%Y")"  > "./tmp/output/$(date +%Y-%m-%d).txt"
```
#### K8s Cron Job

The below assumes that we are logging to /opt/shrtbred/logs and its a nfs storage which allows readwritemany.
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: shrtbred-log-counter
  namespace: shrtbred
spec:
  schedule: "0 5 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: log-counter
            image: amazon/aws-cli
            args:
            - /bin/sh
            - -c
            - cat ./tmp/nginx/shrtbred/nginx.access.log | grep -c "$(date +"%d/%b/%Y")" | aws s3 cp - s3://bucket-name/$(date +%Y-%m-%d).txt"
            env:
             - name: AWS_ACCESS_KEY_ID
               value: something
             - name: AWS_SECRET_ACCESS_KEY
               value: secret
             - name: AWS_DEFAULT_REGION
               value: us-west-2
            volumeMounts:
             - name: logs-storage
               mountPath: /opt/shrtbred/logs
          volumes:
            - name: logs-storage
              persistentVolumeClaim:
                claimName: nfs-logs-pvc
          restartPolicy: OnFailure
```
### Nightly Backup to S3
I would use pgbackrest or WAL-G to accomplish this.

### Horizontal Pod Scaling

```yaml
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: shrtbred-nginx
  labels:
    app.kubernetes.io/instance: shrtbred
    app.kubernetes.io/name: shrtbred-nginx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: shrtbred-nginx
  minReplicas: 5
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: 80
```