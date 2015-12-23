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

heat_client_roles:
  keystone.role_present:
  - names:
    - heat_stack_owner
    - heat_stack_user
  - require:
    - pkg: heat_server_packages

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
