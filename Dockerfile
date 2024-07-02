FROM ubuntu:22.04
RUN apt update && apt install curl postgresql-client lsb-release gnupg2 -y
WORKDIR /app
RUN curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh &&  sh -E nodesource_setup.sh &&  apt update &&  apt install nodejs -y && npm install -g yarn && npm install pg --save
WORKDIR /app/strapi-server
COPY ./ ./
EXPOSE 1337
CMD ["yarn", "start"]

