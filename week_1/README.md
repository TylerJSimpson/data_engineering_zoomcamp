## Dockerfile creation

Creates an image for Docker  
In this case this docker image is for python that utilizes a pipeline.py python pipeline script  
[Dockerfile](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/Dockerfile)

## Python Pipeline creation

Python pipeline script to be called by docker image  
[Pipeline.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/pipeline.py)

## Docker: Postgres image

Using MINGW64 Git Bash on Windows
Note that if there is another local Postgres instance port 5432 will likely need to be changed

```bash
winpty docker run -it  \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /c:/git/data-engineering-zoomcamp/week_1/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13
```
## 

```bash
pip install pgcli
```
