{%- from "heat/map.jinja" import server with context %}
{%- if server.enabled %}

heat_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/heat/heat.conf:
  file.managed:
  - source: salt://heat/files/{{ server.version }}/heat.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: heat_server_packages

/etc/heat/api-paste.ini:
  file.managed:
  - source: salt://heat/files/{{ server.version }}/api-paste.ini
  - template: jinja
  - require:
    - pkg: heat_server_packages

{%- if grains.get('virtual_subtype', None) == "Docker" %}

heat_entrypoint:
  file.managed:
  - name: /entrypoint.sh
  - template: jinja
  - source: salt://heat/files/entrypoint.sh
  - mode: 755

keystonercv3:
  file.managed:
  - name: /root/keystonercv3
  - template: jinja
  - source: salt://heat/files/keystonercv3
  - mode: 755

{%- endif %}

{%- if not grains.get('virtual_subtype', None) == "Docker" %}

{%- if not salt['pillar.get']('linux:system:repo:mirantis_openstack', False) %}

heat_client_roles:
  keystone.role_present:
  - names:
    - heat_stack_owner
    - heat_stack_user
  - connection_user: {{ server.identity.user }}
  - connection_password: {{ server.identity.password }}
  - connection_tenant: {{ server.identity.tenant }}
  - connection_auth_url: 'http://{{ server.identity.host }}:{{ server.identity.port }}/v2.0/'
  - require:
    - pkg: heat_server_packages

{%- endif %}

{%- if server.version != 'juno' %}

heat_keystone_setup:
  cmd.run:
  - name: 'source /root/keystonercv3; heat-keystone-setup-domain --stack-user-domain-name heat_user_domain --stack-domain-admin heat_domain_admin --stack-domain-admin-password {{ server.stack_domain_admin.password }}'
  - shell: /bin/bash
  - require:
    - file: /etc/heat/heat.conf
    - pkg: heat_server_packages
  - require_in:
    - cmd: heat_syncdb

{%- endif %}

{%- endif %}

{%- if not grains.get('noservices', False) %}

heat_syncdb:
  cmd.run:
  - name: heat-manage db_sync
  - require:
    - file: /etc/heat/heat.conf
    - pkg: heat_server_packages

heat_log_access:
  cmd.run:
  - name: chown heat:heat /var/log/heat/ -R
  - require:
    - file: /etc/heat/heat.conf
    - pkg: heat_server_packages
  - require_in:
    - service: heat_server_services

heat_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - require:
    - cmd: heat_syncdb
  - watch:
    - file: /etc/heat/heat.conf
    - file: /etc/heat/api-paste.ini

{%- endif %}

{%- endif %}
