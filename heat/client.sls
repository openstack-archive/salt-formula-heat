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

{%- if client.source.engine == 'git' %}

{{ client.source.address }}:
  git.latest:
  - target: /srv/heat/env
  - rev: {{ client.source.revision }}
  - require:
    - pkg: git_packages
    - file: /srv/heat

{%- endif %}

{%- endif %}