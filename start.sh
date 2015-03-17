#!/bin/bash
sudo docker run -p 5601:5601 -p 9200:9200 -p 9300:9300 -p 24224:24224 -p 80:80 -p 8888:8888 -v `pwd`/data/elastic/log:/data/elastic/log -v `pwd`/data/elastic/data:/data/elastic/data -name docker_fluent_kibana_inst -i -t defk

