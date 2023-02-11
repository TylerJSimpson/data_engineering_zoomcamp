# Week 3: Data Warehousing - BigQuery

## BigQuery: Best Practices

### Cost reduction
* Avoid SELECT *
* Price your queries before running them
* Use clustered and/or partitioned tables
* Use streaming inserts with caution
* Materialize query results in stages

### Query performance
* Filter on partitioned columns
* Denormalizing data
* Use nested or repeated columns
* Use external data sources appropriately
* Reduce data before using a JOIN
* Do not treat WITH clauses as prepared statements
* Avoid oversharding tables
* Avoid JavaScript user-defined functions
* Use approximate aggregation functions (HyperLogLog++)
* Order last for query operations to maximize performance
* Optimize your join patterns
* Place the table with the largest number of rows first, followed by the table with the fewest rows, and then place the remaining tables by decreasing size

## BigQuery: External/Public tables

### Public tables
Public tables can be searched directly in the Explorer.  
Public tables can be queried using the full FROM.  
```sql
-- Query publicly available table
SELECT  station_id, 
        name 
FROM    `bigquery-public-data.new_york_citibike.citibike_stations`
LIMIT   100
;
```
### External tables
External tables can be created directly from GCS files.  
```sql
-- Creating external table with gcs path
CREATE OR REPLACE EXTERNAL TABLE `dtc-de-0315.trips_data_all.external_yellow_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_dtc-de-0315/data/yellow/yellow_tripdata_2019-*.csv.gz', 'gs://dtc_data_lake_dtc-de-0315/data/yellow/yellow_tripdata_2020-*.csv.gz']
);

-- Check yellow trip data
SELECT  * 
FROM    `dtc-de-0315.trips_data_all.external_yellow_tripdata` 
LIMIT   10
;
```

## BigQuery: Partitioning and clustering

### Partitioning
Using external tables above create partitioned and non-partitioned table.  
```sql
-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE `dtc-de-0315.trips_data_all.yellow_tripdata_non_partitoned` 
AS
SELECT  * 
FROM    `dtc-de-0315.trips_data_all.external_yellow_tripdata`
;

-- Create a partitioned table from external table
CREATE OR REPLACE TABLE `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned`
PARTITION BY DATE(tpep_pickup_datetime) AS
SELECT  * 
FROM    `dtc-de-0315.trips_data_all.external_yellow_tripdata`
;
```
Check impact of partitioning.  
```sql
-- non-partitioned
SELECT  DISTINCT(VendorID)
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_non_partitoned` 
WHERE   DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30'
;
-- Processing time: 542 ms
-- Bytes processed: 1.62 GB

-- partitioned
SELECT  DISTINCT(VendorID)
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned`
WHERE   DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30'
;
-- Processing time: 1 sec
-- Bytes processed: 105.91 MB
```
It can be seen that while the processing time increased the bytes processed decreased significantly which will reduce cost.  
You can take a look into the partitions to ensure there is proper distribution.  
```sql
-- Look into partitions
SELECT  table_name, 
        partition_id, 
        total_rows
FROM    `trips_data_all.INFORMATION_SCHEMA.PARTITIONS`
WHERE   table_name = 'yellow_tripdata_partitoned'
ORDER   BY total_rows DESC
;
```
### Clustering
Using external tables above create clustered table from the partitioned table above.
```sql
-- Creating a partition and cluster table
CREATE OR REPLACE TABLE `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned_clustered`
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID 
AS
SELECT  * 
FROM    `dtc-de-0315.trips_data_all.external_yellow_tripdata`
;
```
Check the impact of clustering.  
```sql
-- Non clustered
SELECT  COUNT(*) AS trips
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned`
WHERE   DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
AND     VendorID=1
;
-- Processing time: 770 ms
-- Bytes processed: 1.06 GB

-- Clustered
SELECT  COUNT(*) AS trips
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned_clustered`
WHERE   DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
AND     VendorID=1
;
-- Processing time: 541 ms
-- Bytes processed: 861.8 MB
```
It can be seen that the processing time and bytes processed decreased significantly which will reduce cost.  

## BigQuery: Machine learning
### Model overview
There are many models available in BigQuery without needing to use anything other than SQL.  
![BigQuery_Models](https://cloud.google.com/static/bigquery-ml/images/ml-model-cheatsheet.svg)  
### Create a linear regression model
Investigate the partitioned data from above and decide on which columns to use.  
```sql
-- Select columns of interest
SELECT  passenger_count, 
        trip_distance, 
        PULocationID, 
        DOLocationID, 
        payment_type, 
        fare_amount, 
        tolls_amount, 
        tip_amount
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned` 
WHERE   fare_amount != 0
;
```  
Note that PULocationID, DOLocationID, and payment_type are integers but are categorical.  
These must be converted to strings.  
```sql
-- Create a table for ML with appropriate data types
CREATE OR REPLACE TABLE `dtc-de-0315.trips_data_all.yellow_tripdata_ml` 
(
        `passenger_count` INTEGER,
        `trip_distance` FLOAT64,
        `PULocationID` STRING,
        `DOLocationID` STRING,
        `payment_type` STRING,
        `fare_amount` FLOAT64,
        `tolls_amount` FLOAT64,
        `tip_amount` FLOAT64
) 
AS 
(
SELECT  passenger_count, 
        trip_distance, 
        CAST(PULocationID AS STRING), 
        CAST(DOLocationID AS STRING),
        CAST(payment_type AS STRING), 
        fare_amount, 
        tolls_amount, 
        tip_amount
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned`  
WHERE   fare_amount != 0
)
;
```
Create the default linear regression model.  
```sql
-- Create linear regression model with default settings
CREATE OR REPLACE MODEL `dtc-de-0315.trips_data_all.tip_model`
OPTIONS
(
model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT'
) 
AS
SELECT  *
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_ml`
WHERE   tip_amount IS NOT NULL
;
```
This model will be created under **Models**.  
Here you can check basics such as **Training** and **Evaluation**.  
The feature details can be queried.  
```sql
-- Check features
SELECT  * 
FROM    ML.FEATURE_INFO(MODEL `dtc-de-0315.trips_data_all.tip_model`)
;
```
Note that the fields above converted to strings are now showing as categories.  
Now evaluate the model which will give the statistics necessary for tuning.  
```sql
-- Evaluate the model
SELECT  *
FROM    ML.EVALUATE(MODEL `dtc-de-0315.trips_data_all.tip_model`,
(
SELECT  *
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_ml`
WHERE   tip_amount IS NOT NULL
))
;
```
Now run the prediction.  
```sql
-- Predict the model
SELECT  *
FROM    ML.PREDICT(MODEL `dtc-de-0315.trips_data_all.tip_model`,
(
SELECT  *
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_ml`
WHERE   tip_amount IS NOT NULL
))
;
```
You can also use the explain_predict capability which will return certain characteristics such as the top features.  
```sql
-- Predict and explain
SELECT  *
FROM    ML.EXPLAIN_PREDICT(MODEL `dtc-de-0315.trips_data_all.tip_model`,
(
SELECT  *
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_ml`
WHERE   tip_amount IS NOT NULL
), 
STRUCT(3 AS top_k_features)
)
;
```

Lastly you can tune the hyperparameters.  
There are many more than what I have chosen.  
```sql
-- Hyper parameter tuning
CREATE OR REPLACE MODEL `dtc-de-0315.trips_data_all.tip_hyperparam_model`
OPTIONS
(
model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT',
num_trials=5,
max_parallel_trials=2,
l1_reg=hparam_range(0, 20),
l2_reg=hparam_candidates([0, 0.1, 1, 10])
) 
AS
SELECT  *
FROM    `dtc-de-0315.trips_data_all.yellow_tripdata_ml`
WHERE   tip_amount IS NOT NULL
;
```
