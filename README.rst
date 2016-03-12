
====
Heat
====

Heat is the main project in the OpenStack Orchestration program. It implements an orchestration engine to launch multiple composite cloud applications based on templates in the form of text files that can be treated like code. A native Heat template format is evolving, but Heat also endeavours to provide compatibility with the AWS CloudFormation template format, so that many existing CloudFormation templates can be launched on OpenStack. Heat provides both an OpenStack-native ReST API and a CloudFormation-compatible Query API. 

Sample pillars
==============

Single Heat services on the controller node

.. code-block:: yaml

    heat:
      server:
        enabled: true
        version: icehouse
        region: RegionOne
        bind:
          metadata:
            address: 10.0.106.10
            port: 8000
          waitcondition:
            address: 10.0.106.10
            port: 8000
          watch:
            address: 10.0.106.10
            port: 8003
        cloudwatch:
          host: 10.0.106.20
        api:
          host: 10.0.106.20
        api_cfn:
          host: 10.0.106.20
        database:
          engine: mysql
          host: 10.0.106.20
          port: 3306
          name: heat
          user: heat
          password: password
        identity:
          engine: keystone
          host: 10.0.106.20
          port: 35357
          tenant: service
          user: heat
          password: password
        message_queue:
          engine: rabbitmq
          host: 10.0.106.20
          port: 5672
          user: openstack
          password: password
          virtual_host: '/openstack'
          ha_queues: True

Heat client with specified git templates

.. code-block:: yaml

    heat:
      client:
        enabled: true
        source:
          engine: git
          address: git@repo.domain.com/heat-templates.git
          revision: master

Heat system definition of several stacks/systems 

.. code-block:: yaml

    heat:
      control:
        enabled: true
        system:
          web_production:
            format: hot
            template_file: /srv/heat/template/web_cluster.hot
            environment: /srv/heat/env/web_cluster/prd.env
          web_staging:
            format: hot
            template_file: /srv/heat/template/web_cluster.hot
            environment: /srv/heat/env/web_cluster/stg.env

Ceilometer notification

.. code-block:: yaml

    heat:
      server:
        enabled: true
        version: icehouse
        notification: true

Usage
=====

Install Contrail Heat plugin for additional resources

.. code-block:: bash

    pip install git+https://github.com/Juniper/contrail-heat.git@R1.30

Read more
=========

* http://docs.openstack.org/developer/heat/man/heat-keystone-setup.html
* http://docwiki.cisco.com/wiki/OpenStack_Havana_Release:_High-Availability_Manual_Deployment_Guide


Things to improve
=================

* IBM UrbanCode Deploy - has resources for AWS and VMWare
  http://www.ibm.com/developerworks/rational/library/multi-platform-application-deployment-urbancode-deploy/

