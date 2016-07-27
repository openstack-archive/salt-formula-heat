
====
Heat
====

Heat is the main project in the OpenStack Orchestration program. It implements
an orchestration engine to launch multiple composite cloud applications based
on templates in the form of text files that can be treated like code. A native
Heat template format is evolving, but Heat also endeavours to provide
compatibility with the AWS CloudFormation template format, so that many
existing CloudFormation templates can be launched on OpenStack. Heat provides
both an OpenStack-native ReST API and a CloudFormation-compatible Query API.

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


Client-side RabbitMQ HA setup

.. code-block:: yaml

    heat:
      server:
        ....
        message_queue:
          engine: rabbitmq
          members:
            - host: 10.0.16.1
            - host: 10.0.16.2
            - host: 10.0.16.3
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        ....



Usage
=====

Install Contrail Heat plugin for additional resources

.. code-block:: bash

    pip install git+https://github.com/Juniper/contrail-heat.git@R1.30

Things to improve
=================

* IBM UrbanCode Deploy - has resources for AWS and VMWare
  http://www.ibm.com/developerworks/rational/library/multi-platform-application-deployment-urbancode-deploy/

Documentation and Bugs
============================

To learn how to deploy OpenStack Salt, consult the documentation available
online at:

    https://wiki.openstack.org/wiki/OpenStackSalt

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate bug tracker. If you obtained the software from a 3rd party
operating system vendor, it is often wise to use their own bug tracker for
reporting problems. In all other cases use the master OpenStack bug tracker,
available at:

    http://bugs.launchpad.net/openstack-salt

Developers wishing to work on the OpenStack Salt project should always base
their work on the latest formulas code, available from the master GIT
repository at:

    https://git.openstack.org/cgit/openstack/salt-formula-heat

Developers should also join the discussion on the IRC list, at:

    https://wiki.openstack.org/wiki/Meetings/openstack-salt
Development and testing
=======================

Development and test workflow with `Test Kitchen <http://kitchen.ci>`_ and
`kitchen-salt <https://github.com/simonmcc/kitchen-salt>`_ provisioner plugin.

Test Kitchen is a test harness tool to execute your configured code on one or more platforms in isolation.
There is a ``.kitchen.yml`` in main directory that defines *platforms* to be tested and *suites* to execute on them.

Kitchen CI can spin instances locally or remote, based on used *driver*.
For local development ``.kitchen.yml`` defines a `vagrant <https://github.com/test-kitchen/kitchen-vagrant>`_ or
`docker  <https://github.com/test-kitchen/kitchen-docker>`_ driver.

To use backend drivers or implement your CI follow the section `INTEGRATION.rst#Continuous Integration`__.

A listing of scenarios to be executed:

.. code-block:: shell

  $ kitchen list

  Instance                    Driver   Provisioner  Verifier  Transport  Last Action

  server-cluster-ubuntu-1404  Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  server-cluster-ubuntu-1604  Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  server-cluster-centos-71    Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  server-single-ubuntu-1404   Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  server-single-ubuntu-1604   Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  server-single-centos-71     Vagrant  SaltSolo     Inspec    Ssh        <Not Created>

The `Busser <https://github.com/test-kitchen/busser>`_ *Verifier* is used to setup and run tests
implementated in `<repo>/test/integration`. It installs the particular driver to tested instance
(`Serverspec <https://github.com/neillturner/kitchen-verifier-serverspec>`_,
`InSpec <https://github.com/chef/kitchen-inspec>`_, Shell, Bats, ...) prior the verification is executed.


Usage:

.. code-block:: shell

 # list instances and status
 kitchen list

 # manually execute integration tests
 kitchen [test || [create|converge|verify|exec|login|destroy|...]] [instance] -t tests/integration

 # use with provided Makefile (ie: within CI pipeline)
 make kitchen

