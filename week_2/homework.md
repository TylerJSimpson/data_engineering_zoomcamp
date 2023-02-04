## Week 2 Homework

The goal of this homework is to familiarise users with workflow orchestration and observation. 


## Question 1. Load January 2020 data

Created [etl_web_to_gcs_hw.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/homework/etl_web_to_gcs_hw.py) for this problem.  
Details from the log:  
```
19:39:04.233 | INFO    | Task run 'clean-b9fd7e03-0' - rows: 447770
```

How many rows does that dataset have?

* **447,770**


## Question 2. Scheduling with Cron

Cron is a common scheduling specification for workflows. 

Using the flow in `etl_web_to_gcs.py`, create a deployment to run on the first of every month at 5am UTC. What’s the cron schedule for that?

```bash
prefect deployment build ./etl_web_to_gcs.py:etl_hw2_q2 -n "Parameterized ETL" --cron "0 5 1 * *" -a
```

- `0 5 1 * *`


## Question 3. Loading data to BigQuery 

Created file [etl_web_to_gcs.py]([https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/etl_web_to_gcs.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/homework/etl_web_to_gcs_hw2.py)).
This pulls the February 2019 yellow taxi data code change snippet:  
```python
@flow()
def etl_web_to_gcs() -> None:
    """The main ETL function"""
    color = "yellow"
    year = 2019
    month = 2
```

Using the [etl_gcs_to_bq_hw.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_2/homework) file and changing the parameters to match each of the above 2 files.
February 2019 yellow taxi data code change snippet:  
```python
@flow()
def etl_gcs_to_bq():
    """Main ETL flow to load data into Big Query"""
    color = "yellow"
    year = 2019
    month = 2
```
Imported data to separate tables **rides_yellow_02_2019** and **rides_yellow_03_2019**.  
Rows **rides_yellow_02_2019** : 7,019,375  
Rows **rides_yellow_03_2019** : 7,832,545  


- 14,851,920


## Question 4. Github Storage Block

Created GitHub block using Prefect GUI.  
Block Name:  github-block  
Repository URL: https://github.com/TylerJSimpson/data_engineering_zoomcamp.git  

Created [etl_web_to_gcs_hw2.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_2/homework/etl_web_to_gcs_hw2.py).
Saved in GitHub at data_engineering_zoomcamp/flows/02_gcp/etl_web_to_gcs_hw2.py  

Deployed this script.  
```bash
prefect deployment build ./flows/02_gcp/etl_web_to_gcs_hw2.py:etl_web_to_gcs_hw2 -n "GitHub Storage Flow" -sb github/github-block -o etl_web_to_gcs_hw2_github-deployment.yaml --apply
````

Ran script in the Prefect GUI.  

```
rows: 88605
```

How many rows were processed by the script?

- 88,605



## Question 5. Email or Slack notifications

Created a Teams channel webhook_test.  
Installed "Incoming Webhook"  
Configured "webhook_test"
https://recfi.webhook.office.com/webhookb2/3a19443c-59ec-4bec-8587-71f04b0e6c56@6cadc43b-d2e7-4b13-9f70-9551305e8815/IncomingWebhook/f7015f4ff5b54f9a8745d49f98ee3a33/42306b70-aac5-4ca6-b44d-119c84a6875e

Updating flow from Q4 to include April 2019 Green Taxi data in temporary repo menntioned above.  
```python
@flow()
def etl_web_to_gcs_hw2() -> None:
    """The main ETL function"""
    color = "green"
    year = 2019
    month = 4
    dataset_file = f"{color}_tripdata_{year}-{month:02}"
    dataset_url = f"https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{color}/{dataset_file}.csv.gz"
```

Ran flow from Prefect GUI.  
Received Teams notification.  

How many rows were processed by the script?

- **514,392**


## Question 6. Secrets

Created a secret block in Prefect GUI.  

```python
from prefect.blocks.system import Secret

secret_block = Secret.load("secret-test")

# Access the stored secret
secret_block.get()
```

Value field has 8 asterisks.  

How many characters are shown as asterisks (*) on the next page of the UI?  

- **8**


