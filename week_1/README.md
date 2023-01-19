
## Dockerfile creation

Creates an image for Docker.  
In this case this docker image is for python that utilizes a pipeline.py python pipeline script.  
[Dockerfile](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/Dockerfile)

## Python Pipeline creation

Python pipeline script to be called by docker image.  
[Pipeline.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/pipeline.py)

## Docker: Postgres booting image

Note that if there is another local Postgres instance port 5432 will likely need to be changed.  

```bash
winpty docker run -it  \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /c:/git/data-engineering-zoomcamp/week_1/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13
```
Docker postgres instance now running.  

## Docker: Postgres connecting to image
Install dependencies.  
```bash
pip install pgcli
pip install psycopg_binary
pip install psycopg2-binary
```
Establish connection.  
```bash
winpty pgcli -h localhost -p 5432 -u root -d ny_taxi
```

## Download data
Using NYC cab data from [repo](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow).  
Download data from January 2021 from repo.  

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
```
Explore data.  
```bash
wc -l yellow_tripdata_2021-01.csv 
winpty head -n 100 yellow_tripdata_2021-01.csv 
```
## Python EDA and docker prep
Utilizing Jupyter Notebook.  
```bash
jupyter notebook
```
See code in notebook [upload-data.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/upload-data.ipynb). Due to the size of the csv data this python code creates a table in postgres and appends data in batches of 100,000 records each.  

## Docker: Explore appended data in Postgres
Establish connection as above.  
```bash
winpty pgcli -h localhost -p 5432 -u root -d ny_taxi
```
Check to see all data has been appended and looks correct.  
```sql
SELECT COUNT(*) FROM yellow_taxi_data;
```
Returns 1,369,765 records as expected.  
```sql
SELECT * FROM yellow_taxi_data LIMIT 1;
```
