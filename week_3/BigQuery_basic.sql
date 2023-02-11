-- Query publicly available table
SELECT  station_id, 
        name 
FROM    `bigquery-public-data.new_york_citibike.citibike_stations`
LIMIT   100
;

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

-- Impact of partition

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

-- Look into partitions
SELECT  table_name, 
        partition_id, 
        total_rows
FROM    `trips_data_all.INFORMATION_SCHEMA.PARTITIONS`
WHERE   table_name = 'yellow_tripdata_partitoned'
ORDER   BY total_rows DESC
;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE `dtc-de-0315.trips_data_all.yellow_tripdata_partitoned_clustered`
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID 
AS
SELECT  * 
FROM    `dtc-de-0315.trips_data_all.external_yellow_tripdata`
;

-- Impact of cluster

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
