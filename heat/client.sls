{%- from "heat/map.jinja" import client with context %}
{%- if client.enabled %}

include:
- git

heat_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

heat_client_home:
  file.directory:
  - name: /srv/heat

{%- for tenant_name, tenant in client.tenant.iteritems() %}

{%- if tenant.source.engine == 'git' %}

{{ tenant.source.address }}:
  git.latest:
  - target: /srv/heat/env/{{ tenant_name }}
  - rev: {{ tenant.source.revision }}
  - require:
    - pkg: git_packages
    - file: /srv/heat

{%- endif %}

{%- endfor %}

{%- endif %}