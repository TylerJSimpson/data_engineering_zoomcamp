## Week 3 Homework
Loaded all [fhv data](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv) into GCS.  
Created external table.  
```sql
-- Creating external table
CREATE OR REPLACE EXTERNAL TABLE `dtc-de-0315.trips_data_all.external_fhv_2019`
OPTIONS (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_dtc-de-0315/data/fhv/fhv_tripdata_2019-*.csv.gz']
)
;
```
Created a BQ table (no partitioning or clustering).  
```sql
-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE `dtc-de-0315.trips_data_all.fhv_2019` 
AS
SELECT  * 
FROM    `dtc-de-0315.trips_data_all.external_fhv_2019`
;
```
## Question 1:
What is the count for fhv vehicle records for year 2019?  

```sql
-- Question 1 - count of fhv vehicle records
SELECT  COUNT(*)
FROM    `dtc-de-0315.trips_data_all.fhv_2019` 
;
```
**43,244,696**

## Question 2:
Write a query to count the distinct number of affiliated_base_number for the entire dataset on both the tables.</br> 
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?  

```sql
-- Question 2 - count the distinct number of affiliated_base_number for the entire dataset on both the tables

-- Internal table
SELECT  COUNT(DISTINCT(Affiliated_base_number))
FROM    `dtc-de-0315.trips_data_all.fhv_2019`
;

-- External table
SELECT  COUNT(DISTINCT(Affiliated_base_number))
FROM    `dtc-de-0315.trips_data_all.external_fhv_2019`
;
```

Internal table query size prediction:  
**This query will process 317.94 MB when run.**  
Internal table query size prediction:  
**This query will process 0 B when run.**  

**0 MB for the External Table and 317.94MB for the BQ Table** 


## Question 3:
How many records have both a blank (null) PUlocationID and DOlocationID in the entire dataset?  

```sql
-- Question 3 - How many records have both a blank (null) PUlocationID and DOlocationID in the entire dataset?
SELECT  COUNT(*)
FROM    `dtc-de-0315.trips_data_all.fhv_2019`
WHERE   PUlocationID IS NULL
AND     DOlocationID IS NULL
;
```
**717,748**


## Question 4:
What is the best strategy to optimize the table if query always filter by pickup_datetime and order by affiliated_base_number?  
**Partition by pickup_datetime Cluster on affiliated_base_number**  


## Question 5:
Implement the optimized solution you chose for question 4. Write a query to retrieve the distinct affiliated_base_number between pickup_datetime 2019/03/01 and 2019/03/31 (inclusive).</br> 
```sql
-- Creating a partition and cluster table
CREATE OR REPLACE TABLE `dtc-de-0315.trips_data_all.fhv_2019_partitoned_clustered`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY Affiliated_base_number 
AS
SELECT  * 
FROM    `dtc-de-0315.trips_data_all.fhv_2019`
;
```

Use the BQ table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values? Choose the answer which most closely matches.  
```sql
-- Check estimated bytes of query on non-partitioned/clustered table
SELECT  DISTINCT(Affiliated_base_number)
FROM    `dtc-de-0315.trips_data_all.fhv_2019`
WHERE   pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31'
;

-- Check estimated bytes of query on partitioned/clustered table
SELECT  DISTINCT(Affiliated_base_number)
FROM    `dtc-de-0315.trips_data_all.fhv_2019_partitoned_clustered`
WHERE   pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31'
;
```
Non-partitioned/clustered table:  
**This query will process 647.87 MB when run.**  
Partitioned and clustered table:  
**This query will process 23.05 MB when run.**  

**647.87 MB for non-partitioned table and 23.06 MB for the partitioned table**  


## Question 6: 
Where is the data stored in the External Table you created?  
The data is stored in GCS in a bucket. In BigQuery external tables the data remains with the source.  

**GCP Bucket**



## Question 7:
It is best practice in Big Query to always cluster your data:  
There are reasons not to cluster data. When new data is added it must be clustered again which can bring more cost than benefit if data is added frequently.  
Further, if you have a small dataset that is mostly distributed uniformly the cost of clustering will bring little to no benefit.  
**False**

