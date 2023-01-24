# Homework week_1

## Question 1: Knowing docker tags
### Which tag has the following text? - Write the image id to the file
SSH into VM.  
```bash
ssh -i /c/Users/simps/.ssh/gcp tjsimpson@{HIDDEN}
```
Look for build commands matching the text.  
```bash
docker build --help
```
Answer: **--iidfile string**  

## Question 2: Understanding docker first run
### How many python packages/modules are installed?
SSH into VM.  
```bash
ssh -i /c/Users/simps/.ssh/gcp tjsimpson@{HIDDEN}
```
Run docker with python:3.0 image in interactive mode with bash entrypoint.  
```bash
docker run -it python:3.9 bash
```
Use pip list to count python packages/modules installed.  
```bash
pip list
```
Answer: **3**  

## Question 3: Count records
### How many taxi trips were totally made on January 15?  
If VM was shut off ensure ports 5432, 8080, and 8888 are forwarded again.  
SSH into VM.  
```bash
ssh -i /c/Users/simps/.ssh/gcp tjsimpson@{HIDDEN}
```
Change to week_1_basics_n_setup/2_docker_sql directory.  
Start pg database and pg admin.  
```bash
docker-compose up -d
```
Download data.  
```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-01.csv.gz
```
```bash
wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv
```
Open Jupyter Notebook.  
```bash
jupyter notebook
```
Copy URL to web browser.  
Opening upload-data.ipynb because it has most of the code completed.  
Copying code used into single block:  
```python
#import packages
import pandas as pd
!pip install psycopg2-binary
from sqlalchemy import create_engine
from time import time

#import green-tripdata_2019-01
df_iter = pd.read_csv('green_tripdata_2019-01.csv.gz', iterator=True, chunksize=100000)
df = next(df_iter)
df.head(n=0).to_sql(name='green_taxi_data', con=engine, if_exists='replace')
df.to_sql(name='green_taxi_data', con=engine, if_exists='append')
while True: 
    t_start = time()

    df = next(df_iter)

    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)
    
    df.to_sql(name='green_taxi_data', con=engine, if_exists='append')

    t_end = time()

    print('inserted another chunk, took %.3f second' % (t_end - t_start))
    
#import green-tripdata_2019-01 once above processes
!wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv
df_zones = pd.read_csv('taxi+_zone_lookup.csv')
df_zones.to_sql(name='zones', con=engine, if_exists='replace')
```
SQL Query:  
```sql
SELECT	COUNT(*)
FROM	green_taxi_data
WHERE	lpep_pickup_datetime::DATE = '2019-01-15'
AND	lpep_dropoff_datetime::DATE = '2019-01-15'
;
```
Answer: **20530**

## Question 4: Largest trip for each day
### Which was the day with the largest trip distance
SQL Query:  
```sql
SELECT	lpep_pickup_datetime,
	trip_distance
FROM	green_taxi_data
ORDER	BY trip_distance DESC
LIMIT	10
;
```
Answer: **2019-01-15**  

## Question 5: The number of passengers
### In 2019-01-01 how many trips had 2 and 3 passengers?
SQL Query:  
```sql
SELECT	MAX(lpep_pickup_datetime),
	passenger_count,
	COUNT(passenger_count) AS num_trips
FROM	green_taxi_data
WHERE	lpep_pickup_datetime::DATE = '2019-01-01'
GROUP	BY passenger_count
;
```
Answer: **2:1282;3:254**  
## Question 6: Largest tip
### For the passengers picked up in the Astoria Zone which was the drop up zone that had the largest tip?
Get LocationID of Astoria zone:  
```sql
SELECT	*
FROM	zones
WHERE	"Zone" like '%Astoria%'
;
```
LocationID = 7  
Find drop off location ID where tip was largest and pickup LocationID = 7:  
```sql
SELECT	tip_amount,
	"DOLocationID"
FROM	green_taxi_data
WHERE	"PULocationID" = 7
ORDER	BY tip_amount DESC
LIMIT	10
;
```
DOLocationID = 146  
Find zone name:  
```sql
SELECT	*
FROM	zones
WHERE	"LocationID" = 146
;
```
Answer: **Long Island City/Queens Plaza**
