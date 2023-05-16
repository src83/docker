FROM nginx:1.20.1

ARG PROJECT_ENV
ARG TIME_ZONE

ENV DEBIAN_FRONTEND noninteractive

## Install dependencies
RUN apt update && apt -y upgrade
RUN apt -y install --no-install-recommends apt-utils
RUN apt -y install \
    dnsutils \
    htop \
    locales \
    vim \
    mc \
    net-tools \
    nmap \
    smartmontools \
    traceroute \
    sudo \
    zip

# Clear cache
RUN apt clean && rm -rf /var/lib/apt/lists/*


# General settings
RUN ln -snf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && echo ${TIME_ZONE} > /etc/timezone

# Create run dir
RUN mkdir -p /run/nginx

# Copy custom config files into container
COPY ./ /etc/nginx

# Delete unused stuff
RUN rm -f /etc/nginx/fastcgi_params \
/etc/nginx/scgi_params \
/etc/nginx/uwsgi_params \
/etc/nginx/conf.d/default.conf

# Setup main config
RUN ln -s /etc/nginx/configs/local.conf /etc/nginx/conf.d/default.conf

# Expose ports and start Nginx server
EXPOSE 80 443

CMD ["nginx","-g","daemon off;"]
