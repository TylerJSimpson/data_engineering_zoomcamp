# Week 2: Prefect - Workflow Automation

Table of contents
=================

<!--ts-->
   * [Placeholder_1](#Prefect_Pipeline_Web_to_GCS)
   * [Placeholder_2](#placeholder2)
<!--te-->

Prefect_Pipeline_Web_to_GCS
=================

Connect to VM.  
```bash
ssh -i /c/Users/simps/.ssh/gcp tjsimpson@{hidden}
```

Authenticate gcloud via OAuth.  
```bash
gcloud auth application-default login
```

Move to /week_2_workflow_orchestration/  

Clone git repository.  
```bash
git clone https://github.com/discdiver/prefect-zoomcamp.git
```

Move to /week_2_workflow_orchestration/prefect-zoomcamp/  

Create Conda environment.  
```bash
conda create -n zoom python=3.9
```

Connec to environment.  
```bash
conda activate zoom
```

Install requirements.  
```bash
pip install -r requirements.txt
```

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

Create Prefect block in the GUI.  
Block Name: zoom-gcs  
Bucket (from GCS): dtc_data_lake_dtc-de-0315  

Create Prefect GCP Credentials using service account.  
Block Name: zoom-gcp-creds  
Add GCP service account json key.  
Now add this credential to the optional credential portion of the GSC bucket block.  
Create.  
The python code will need to be added to the python pipeline code.  

```python
from prefect_gcp.cloud_storage import GcsBucket
gcp_cloud_storage_bucket_block = GcsBucket.load("zoom-gcs")
```

Create Prefect flow to gather web data and store it in GCS:  
[etl_web_to_gcs.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/etl_web_to_gcs.py)  

Run file from /week_2_workflow_orchestration/prefect-zoomcamp/  

```bash
python flows/02_gcp/etl_web_to_gcs.py
```

Can check flow runs in Prefect and can see the data in GCS.  

Create [rides] table in [BigQuery](https://console.cloud.google.com/bigquery).  

Create Prefect flow to gather data from GCS (data lake) and insert into bigquery.  
[etl_gcs_to_bq.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/etl_gcs_to_bq.py)  
Include destination_table and project_id from BigQuery for integration.  

Run python pipeline.  
```bash
python flows/02_gcp/etl_web_to_gcs.py
```
Check BigQuery to be sure data has loaded successfully after receiving a success message.


Placeholder2
=================
