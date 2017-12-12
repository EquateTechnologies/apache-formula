{% from "apache/map.jinja" import apache with context %}

{% if grains['os_family']=="Debian" %}

include:
  - apache

a2enmod mod_ssl:
  cmd.run:
    - name: a2enmod ssl
    - unless: ls /etc/apache2/mods-enabled/ssl.load
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

{% elif grains['os_family']=="RedHat" %}

include:
  - apache

mod_ssl:
  pkg.installed:
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

{% if 'ssl' in apache and apache.ssl.get('config_source', False) != False %}
mod_ssl_config:
  file.managed:
    - name: /etc/httpd/conf.d/ssl.conf
    - source: {{ apache.ssl.get('config_source') }}
    {% if apache.ssl.get('config_source_template', False) != False %}
    - template: {{ apache.ssl.get('config_source_template') }}
    {% endif %}
    - require:
      - pkg: mod_ssl
    - watch_in:
      - module: apache-restart
{% endif %}

{% elif grains['os_family']=="FreeBSD" %}

include:
  - apache
  - apache.mod_socache_shmcb

{{ apache.modulesdir }}/010_mod_ssl.conf:
  file.managed:
    - source: salt://apache/files/{{ salt['grains.get']('os_family') }}/mod_ssl.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

{% endif %}
