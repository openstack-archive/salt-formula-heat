{%- from "heat/map.jinja" import control with context %}
{%- for system_name, system in control.system.iteritems() %}

heat_stack_{{ system_name }}:
  heat.stack_present:
  - name: {{ system_name }}
  {%- if system.template_file is defined %}
  - template_file: {{ system.template_file }}
  {%- endif %}
  {%- if system.environment_file is defined %}
  - environment_file: {{ system.environment_file }}
  {%- endif %}

{%- endfor %}