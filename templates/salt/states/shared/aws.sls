locales:
  pkg:
    - installed

{% if grains['os'] == 'Debian' %}
locales-all:
  pkg:
    - installed
{% endif %}

git:
  pkg:
    - installed
