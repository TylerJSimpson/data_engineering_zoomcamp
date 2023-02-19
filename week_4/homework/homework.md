## Week 4 Homework 

Please see my code for the following:

* models/staging/[stg_fhv_tripdata.sql](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_4/homework/models/staging/stg_fhv_tripdata.sql)
* models/staging/[schema.yml](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_4/homework/models/staging/schema.yml)
* models/core/[fact_fhv_trips.sql](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_4/homework/models/core/fact_fhv_trips.sql)
* models/core/[schema.yml](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_4/homework/models/core/schema.yml)
* dashboard


### Question 1: 

**What is the count of records in the model fact_trips after running all models with the test run variable disabled and filtering for 2019 and 2020 data only (pickup datetime)** 

Record count of fact_trips in BigQuery details page:  
61,636,378  

Closest option:  
**61648442**  

### Question 2: 

**What is the distribution between service type filtering by years 2019 and 2020 data as done in the videos**

You will need to complete "Visualising the data" videos, either using data studio or metabase.  

My original [dashboard](https://lookerstudio.google.com/s/kfnV1LcxmcI) answers this question.  

**89.9/10.1**



### Question 3: 

**What is the count of records in the model stg_fhv_tripdata after running all models with the test run variable disabled (:false)**  

Create a staging model for the fhv data for 2019 and do not add a deduplication step. Run it via the CLI without limits (is_test_run: false).
Filter records with pickup time in year 2019.

```sql
SELECT  COUNT(*) 
FROM    `dtc-de-0315.dbt_cloud_pr_218904_5.stg_fhv_tripdata`
```
Result:  
43244693  

Closest option:  
**43244696**  

### Question 4: 

**What is the count of records in the model fact_fhv_trips after running all dependencies with the test run variable disabled (:false)**  

Create a core model for the stg_fhv_tripdata joining with dim_zones.
Similar to what we've done in fact_trips, keep only records with known pickup and dropoff locations entries for pickup and dropoff locations. 
Run it via the CLI without limits (is_test_run: false) and filter records with pickup time in year 2019.

Record count of fact_fhv_trips in BigQuery details page:  
**22,998,722**  

### Question 5: 

**What is the month with the biggest amount of rides after building a tile for the fact_fhv_trips table**
Create a dashboard with some tiles that you find interesting to explore the data. One tile should show the amount of trips per month, as done in the videos for fact_trips, based on the fact_fhv_trips table.

Created a [visual](https://lookerstudio.google.com/s/jYdIDO070NY) and also double checked in BigQuery. January is by far the largest month.

**January**

