heat:
  server:
    enabled: true
    region: RegionOne
    version: liberty
    stack_domain_admin:
      name: heat_domain_admin
      password: password
      domain: heat
    bind:
      api_cfn:
        address: 127.0.0.1
      api_cloudwatch:
        address: 127.0.0.1
      api:
        address: 127.0.0.1
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: heat
      user: heat
      password: password
    metadata:
      host: 127.0.0.1
      port: 8000
    waitcondition:
      host: 127.0.0.1
      port: 8000
    watch:
      host: 127.0.0.1
      port: 8003
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: heat
      password: password
      admin_tenant: admin
      admin_user: admin
      admin_password: admin
    message_queue:
      engine: rabbitmq
      members:
      - host: 127.0.0.1
      - host: 127.0.1.1
      - host: 127.0.2.1
      user: openstack
      password: password
      virtual_host: '/openstack'
