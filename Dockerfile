# Pull base image.
FROM dockerfile/java
MAINTAINER Harley Bussell <modmac@gmail.com>

# Install ElasticSearch.
RUN \
  cd /tmp && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz && \
  tar xvzf elasticsearch-1.4.4.tar.gz && \
  rm -f elasticsearch-1.4.4.tar.gz && \
  mv /tmp/elasticsearch-1.4.4 /elasticsearch

# Install Fluentd.
RUN wget http://packages.treasuredata.com/2/ubuntu/trusty/pool/contrib/t/td-agent/td-agent_2.0.4-0_amd64.deb &&\
    dpkg -i td-agent_2.0.4-0_amd64.deb &&\
    apt-get update &&\
    apt-get install make libcurl4-gnutls-dev --yes &&\
    /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-elasticsearch &&\
    /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-record-reformer

ADD config/etc/td-agent/td-agent.conf /etc/td-agent/td-agent.conf


# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Replace nginx default site with Kibana, making it accessible on localhost:80.
RUN unlink /etc/nginx/sites-enabled/default
ADD config/etc/nginx/kibana.conf /etc/nginx/sites-enabled/default

# Install Kibana.
RUN \
  cd /tmp && \
  wget https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz &&\
  tar xvzf kibana-4.0.1-linux-x64.tar.gz && \
  rm -f kibana-4.0.1-linux-x64.tar.gz && \
  mv kibana-4.0.1-linux-x64 /usr/share/kibana

#RUN cp -R /usr/share/kibana/* /

# Copy kibana config.
#ADD config/etc/kibana/config.js /usr/share/kibana/config.js
ADD config/etc/kibana/kibana.yml /usr/share/kibana/config/kibana.yml

# Install supervisord.

RUN apt-get install -y --no-install-recommends supervisor

# Copy supervisor config.
ADD config/etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf


#CMD ["fluentd", "--conf=/etc/fluent/fluent.conf"]


# Define mountable directories.
VOLUME ["/data", "/var/log", "/etc/nginx/sites-enabled"]

# Define working directory.
WORKDIR /
# Define default command.
#CMD ["/elasticsearch/bin/elasticsearch"]


# Set default command to supervisor.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# Expose Elasticsearch ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300

# Expose Fluentd port.
EXPOSE 24224
# Fluent Post Input HTTP
EXPOSE 8888 

# Expose Kibana port.
EXPOSE 5601

# Expose nginx http ports
EXPOSE 80
EXPOSE 443

