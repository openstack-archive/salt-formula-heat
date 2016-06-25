{%- from "heat/map.jinja" import server with context -%}
#!/bin/bash -e

cat /srv/salt/pillar/heat-server.sls | envsubst > /tmp/heat-server.sls
mv /tmp/heat-server.sls /srv/salt/pillar/heat-server.sls

salt-call --local --retcode-passthrough state.highstate

{% for service in server.services %}
service {{ service }} stop || true
{% endfor %}

if [ "$1" == "api" ]; then
    echo "starting heat-api"
    su heat --shell=/bin/sh -c '/usr/bin/python /usr/bin/heat-api --config-file=/etc/heat/heat.conf'
elif [ "$1" == "api-cfn" ]; then
    echo "starting heat-api-cfn"
    su heat --shell=/bin/sh -c '/usr/bin/python /usr/bin/heat-api-cfn --config-file=/etc/heat/heat.conf'
elif [ "$1" == "engine" ]; then
    echo "starting heat-engine"
    su heat --shell=/bin/sh -c '/usr/bin/python /usr/bin/heat-engine --config-file=/etc/heat/heat.conf'
elif [ "$1" == "api-cloudwatch" ]; then
    echo "starting heat-api-cloudwatch"
    su heat --shell=/bin/sh -c '/usr/bin/python /usr/bin/heat-api-cloudwatch --config-file=/etc/heat/heat.conf'
else
    echo "No parameter submitted, don't know what to start" 1>&2
fi

{#-
vim: syntax=jinja
-#}