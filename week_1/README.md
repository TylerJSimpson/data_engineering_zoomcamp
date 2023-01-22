# Week 1: Docker, GCP, and Terraform 

Table of contents
=================

<!--ts-->
   * [Docker](#docker)
   * [Terraform_and_GCP](#terraform_and_gcp)
<!--te-->

Docker
=================

### Docker compile Postgres and PGadmin containers in a network to allow for GUI interaction with database. Python data pipeline container feeding the Postgres database.

## Docker: Postgres image

### Create and run Postgres image.

```bash
winpty docker run -it  \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /c:/git/data-engineering-zoomcamp/week_1/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13
```

### Connect to Postgres image.  
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



## Docker: Python data pipeline feed to Postgres

### Download and explore data

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
### Python EDA and docker prep

Open Jupyter Notebook.  

```bash
jupyter notebook
```  

Develop code in notebook [upload-data.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/upload-data.ipynb).  
Due to the size of the csv data this python code creates a table in Postgres and appends data in batches of 100,000 records each.  

### Convert python notebook to script
ipynb exploratory notebook developed previously:  
[upload-data.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/upload-data.ipynb)  
  
Convert to script:  
```bash
winpty jupyter nbconvert --to=script upload-data.ipynb
```  
Clean up script and add argparse arguments and parameters:  
[ingest_data.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/ingest_data.py)  

Test ingestion of pipeline into docker.  
```bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

winpty python ingest_data.py \
  --user=root \
  --password=root \
  --host=localhost \
  --port=5432 \
  --db=ny_taxi \
  --table_name=yellow_taxi_trips \
  --url=${URL}
```  
Added zones data to [upload-data.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/upload-data.ipynb) after the fact. This portion is not active in the Docker compile file mentioned later.  
```python
import pandas as pd
from sqlalchemy import create_engine
engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
engine.connect()
!wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv
df_zones = pd.read_csv('taxi+_zone_lookup.csv')
df_zones.to_sql(name='zones', con=engine, if_exists='replace')
```  
### Explore appended data in Postgres
Establish connection.  
```bash
winpty pgcli -h localhost -p 5432 -u root -d ny_taxi
```
Check to see all data has been appended and looks correct.  
```sql
SELECT	COUNT(*) 
FROM 	yellow_taxi_data;
```
Returns 1,369,765 records as expected.  
```sql
SELECT	* 
FROM 	yellow_taxi_data 
LIMIT 	1;
```
## Docker: Create PGadmin image

Create and run PGadmin image.  
```bash
winpty docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  dpage/pgadmin4
```
Search in browser: localhost:8080 and login with credentials specified.  
  
Now there are 2 containers:   
* container with Postgres running
* container with PGadmin running  
  
A docker network must be created to link the 2 containers.  

## Docker: Create network  
Create network.  
```bash
winpty docker network create pg-network
```  
Add Postgres image.  
```bash
winpty docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /c:/git/data-engineering-zoomcamp/week_1/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --network=pg-network \
  --name pg-database \
  postgres:13
```
Add PGadmin image.  
```bash
winpty docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  --network=pg-network \
  --name pgadmin2 \
  -p 8080:80 \
  dpage/pgadmin4
```  



## Dockerfile and Docker Compose creation

### Dockerfile creation

Creates an image for Docker including the dependencies for Postgres, PGadmin, and the ingest_data.py script.     
[Dockerfile](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/Dockerfile)  

### Docker Compose creation
Combine Postgres image, PGadmin image, and python data pipeline image into a single docker compose instance.  
Build new image.  
```bash
docker build -t taxi_ingest:v001 .
``` 
Run build in the network.  
--network needs added and --host must be changed from localhost now that this is on a network.  
```bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

winpty docker run -it \
  --network=pg-network \
  taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```  
Create docker compose file:  
[docker-compose.yaml](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_1/docker-compose.yaml)  
Execute:  
```bash
docker-compose up
``` 
## Postgres SQL development in PGadmin 
### Join [yellow_taxi_trips] and [zones]  
```sql
/* Join [yellow_taxi_trips] and [zones] */

SELECT	tpep_pickup_datetime,
  	tpep_dropoff_datetime,
  	total_amount,
  	CONCAT(zpu."Borough", ' / ', zpu."Zone")    AS "pickup_loc",
  	CONCAT(zdo."Borough", ' / ' , zpu."Zone")   AS "dropoff_loc"
FROM	yellow_taxi_trips t 
	JOIN zones zpu
  		ON t."PULocationID" = zpu."LocationID"
	JOIN zones zdo
  		ON t."DOLocationID" = zdo."LocationID"
LIMIT   100;
```  
### Check for clean data   
1. Check for data without pickup or dropoff locations:
```sql
/* Check for data without a pickup or dropoff location */
SELECT	tpep_pickup_datetime,
  	tpep_dropoff_datetime,
  	total_amount,
  	"PULocationID",
  	"DOLocationID"
FROM	yellow_taxi_trips t
WHERE	"DOLocationID" is NULL --replace with "PULocationID" to check null pickup locations
LIMIT   100;
```  
There are no missing pickup or dropoff locations.  
  
2. Check for pickup and dropoff locations not present in the zones table
```sql
/* Check for dropoff and pickup locations not present in [zones] */
SELECT	tpep_pickup_datetime,
  	tpep_dropoff_datetime,
  	total_amount,
  	"PULocationID",
  	"DOLocationID"
FROM	yellow_taxi_trips t
WHERE   "DOLocationID" NOT IN (SELECT "LocationID" FROM zones) -- replace with "PULocationID" to check if pickup locations are not in the zones table
LIMIT 	100;
```  
There are no missing locations.  

Terraform_and_GCP
=================

### Installation and setup of GCP, GCP SDK, and Terraform. Building BigQuery and Google Cloud Storage (GCS) infrastructure using Terraform.

## GCP SDK setup

Download and install [GCP SDK](https://cloud.google.com/sdk/docs/install) and ensure PATH is set.  
Be sure the PATH is set for the python.exe that will be used.  
  
Link GCP SDK to account key.  
```bash
export GOOGLE_APPLICATION_CREDENTIALS="C:\git\data-engineering-zoomcamp\week_1\gcp\dtc-de-0315-7c3955b32bd3.json"
```  
  
Authenticate using OAuth.  
```bash
gcloud auth application-default login
```  
  
Add quota project.  
```bash
gcloud auth application-default set-quota-project {PROJECT ID HIDDEN}
```  
  
Link GCP SDK to project.  
```bash
PROJECT_NAME="{PROJECT ID HIDDEN}"
gcloud auth application-default set-quota-project ${PROJECT_NAME}
```  

Grant service account IAM permissions in GUI:  
* Storage Admin  
* Storage Object Admin  
* BigQuery Admin  

Enable [IAM API access](https://console.cloud.google.com/apis/library/iam.googleapis.com)  
Enable [IAM secive account credentials API](https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com)  


## Terraform GCP infrastructure creation  

Infrastructure to be created:
* Create GCP infrastructure modules.
* Google Cloud Storage (GCS): Data Lake
* BigQuery: Data Warehouse
  
Download and install [terraform](https://www.terraform.io/) and ensure PATH is set.  


Create [Terraform folder](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_1/terraform) to house files:  
* Create file [main.tf](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_1/terraform/main.tf)  
* Create file [variables.tf](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_1/terraform/variables.tf)  
  
*Please note that in this variables.tf file setup the project ID is passed at runtime.*  

Refresh GCP credentials with OAuth.  
```bash
gcloud auth application-default login
```

Initialize terraform from [Terraform folder](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_1/terraform).  
```bash
terraform init
```

Plan setup and review details.  
```bash
terraform plan
```

Build all GCP resources.  
```bash
terraform apply
```

To save money please remember to delete the resources.  
```bash
terraform destroy
```

