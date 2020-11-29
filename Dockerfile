FROM rocker/shiny:latest

MAINTAINER Arthur Saakyan "arthur.saakyan.93@gmail.com"

# system libraries of general use
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# system library dependency for my app
#RUN apt-get update && apt-get install -y \
#    libmpfr-dev

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# install dependencies of my app
RUN R -e "install.packages(c('dplyr', 'nycflights13', 'viridis', 'lubridate'), repos='https://cloud.r-project.org/')"

# copy the app to the image
RUN mkdir /root/flights_stats
COPY /flights_stats /root/flights_stats

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/flights_stats')"]
