FROM redis:7.0.0

ARG TIME_ZONE

## Install dependencies
RUN apt update && apt -y upgrade
RUN apt -y install --no-install-recommends apt-utils
RUN apt -y install htop locales vim mc

# Clear cache
RUN apt clean && rm -rf /var/lib/apt/lists/*


# General settings
RUN ln -snf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && echo ${TIME_ZONE} > /etc/timezone

# Copy default config file into container
COPY redis.conf /usr/local/etc/redis.conf

# Copy init script into container
COPY redis-init.sh /usr/local/bin/redis-init.sh
RUN chmod +x /usr/local/bin/redis-init.sh

# Expose port and start Redis server
#EXPOSE 6379

CMD ["sh","-c","/usr/local/bin/redis-init.sh"]
