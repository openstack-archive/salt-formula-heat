{%- if pillar.heat is defined %}
include:
{%- if pillar.heat.server is defined %}
- heat.server
{%- endif %}
{%- if pillar.heat.client is defined %}
- heat.client
{%- endif %}
{%- endif %}