# Some calculation example

## About

Sonme people think that NodeJS is for creating a `backend` for a web project. But actually NodeJS is just a javascript runtime environment. You can create a web server but you can also use it to do write a simple calculation program.

This example is just that: the program receives command line parameters and calculates the surface of circumfence of a circle.

## How to run

In this folder you'll find a `docker-compose.yml` file. You can run it using [Docker compose](https://docs.docker.com/get-started/08_using_compose/).

Open a terminal and run docker compose in this folder

```bash
# Use `cd` to go to this folder first

# 
# Run the docker-compose.yml file
# 
docker compose up
```

The example will run using `nodemon`, which means it will reload if you change the javascript source. Have fun!
