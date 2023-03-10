# Week 2: Prefect - Workflow Automation
Prefect is a python workflow and data pipeline automation tool born out of Airflow. We will setup Prefect and develop pipelines from source to object store and from object store to datawarehouse. We will also paramaterize the pipelines and deploy them in Docker.  
## General Setup

### Connect to VM

Use bash script or connect via VScode.
```bash
ssh -i /c/Users/simps/.ssh/gcp tjsimpson@{hidden}
```
### Forward the necessary ports in VScode
PORTS -> FORWARD PORT -> 5432  
PORTS -> FORWARD PORT -> 8080  
PORTS -> FORWARD PORT -> 8888  
PORTS -> FORWARD PORT -> 4200  


### Authenticate gcloud via OAuth.  
```bash
gcloud auth application-default login
```

### Clone this week's git repo
Move to /week_2_workflow_orchestration/  

```bash
git clone https://github.com/discdiver/prefect-zoomcamp.git
```
### Create and activate Conda environment with requirements

Move to /week_2_workflow_orchestration/prefect-zoomcamp/  

Create Conda environment.  
```bash
conda create -n zoom python=3.9
```

Connect to environment.  
```bash
conda activate zoom
```

Install requirements.  
```bash
pip install -r requirements.txt
```

## Prefect

### Prefect Setup

Install Prefect.  
```bash
pip install prefect -U
```

Check Prefect version.  
```bash
prefect version
```

Move to /week_2_workflow_orchestration/prefect-zoomcamp/  

GCS created previously via Terraform but can be created in the GCP [console](console.cloud.google.com/storage/)  

Prefect can be accessed by clicking the link generated upon running this script.  
```bash
prefect orion start
```

**Create Prefect block in the GUI.**  
Block Name: zoom-gcs  
Bucket (from GCS): dtc_data_lake_dtc-de-0315  

**Create Prefect GCP Credentials using service account.**  
Block Name: zoom-gcp-creds  
Add GCP service account json key.  
Now add this credential to the optional credential portion of the GSC bucket block.  
Create.  
The python code will need to be added to the python pipeline code written in the next step.  

```python
from prefect_gcp.cloud_storage import GcsBucket
gcp_cloud_storage_bucket_block = GcsBucket.load("zoom-gcs")
```

### Prefect Pipeline: ETL data from the web to GCS

Create Prefect flow to gather web data and store it in GCS:  
[etl_web_to_gcs.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/etl_web_to_gcs.py)  

Run file from /week_2_workflow_orchestration/prefect-zoomcamp/  

```bash
python flows/02_gcp/etl_web_to_gcs.py
```

Can check flow runs in Prefect and can see the data in GCS.  

### Prefect Pipeline: ETL data from GCS to BigQuery

Create [rides] table in [BigQuery](https://console.cloud.google.com/bigquery).  

Create Prefect flow to gather data from GCS (data lake) and insert into bigquery.  
[etl_gcs_to_bq.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/etl_gcs_to_bq.py)  
Include destination_table and project_id from BigQuery for integration.  

Run python pipeline.  
```bash
python flows/02_gcp/etl_web_to_gcs.py
```
Check BigQuery to be sure data has loaded successfully after receiving a success message.

### Prefect Pipeline: Parameterize

Parameterize the previous pipelines into a parent pipeline.  
[parameterized_flow.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/parameterized_flow.py)  

Now create a deployment with the pipeline.  
```bash
prefect deployment build ./parameterized_flow.py:etl_parent_flow -n "Parameterized ETL"
```

This generates file [etl_parent_flow-deployment.yaml](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/etl_parent_flow-deployment.yaml)..  
Add parameters.  
```yaml
parameters: {"color": "yellow", "months" :[1 ,2 ,3], "year": 2021}
```

Apply changes and finalize deployment creation.  
```bash
prefect deployment apply etl_parent_flow-deployment.yaml
```

Deployment now available in the Prefect GUI.  

To run this you must activate a work queue agent.  
```bash
prefect agent start  --work-queue "default"
```

Note that if the @task() def write_local is used you may need to alter the path if deployment is from a different directory than testing.  
```python
path = Path(f"../../data/{color}/{dataset_file}.parquet")
```
Alternatively you can create a new directory.  

Note Notifications and Schedules can be set up in the GUI.  

You can also use cron to set schedules on build.  
Example code below will create a new deployment that runs every day at 12:00 AM.
```bash
prefect deployment build ./parameterized_flow.py:etl_parent_flow -n "Parameterized ETL" --cron "0 0 * * *" -a
```

## Docker

### Docker Setup

Saving flow code as docker container to productionize.  

Create [Dockerfile](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/Dockerfile)  
Create [docker-requirements](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/docker-requirements.txt)

Build Docker image.  
```bash
docker image build -t tjsimpson/prefect:zoom .
```

Log in to Docker hub.  
```bash
docker login
```

Push docker image to Docker hub.  
```bash
docker image push tjsimpson/prefect:zoom
```

Create Docker Block (in Prefect) for use in deployment.  
In options set Image to "tjsimpson/prefect:zoom"  
ImagePullPolicy "ALWAYS"  
Auto Remove "ON"  
Create to generate code for deployment.  
```python
from prefect.infrastructure.docker import DockerContainer

docker_container_block = DockerContainer.load("zoom")
```
### Docker Image: Prefect Pipeline

Create prefect pipeline flow deployment via python.  
[docker_deploy.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/docker-deploy.py)  

Deploy.  
```bash
python docker_deploy.py
```

Allow docker file to interface with Prefect Orion server.  
First ensure you're using the correct Prefect login.  
```bash
prefect profile ls
```
Specify the API endpoint.  
```bash
prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
```

Start up Prefect work queue.  
```bash
prefect agent start  --work-queue "default"
```

Run flow and overide parameter months with just 1 and 2.  
```bash
prefect deployment run etl-parent-flow/docker-flow -p "months=[1,2]"
```
