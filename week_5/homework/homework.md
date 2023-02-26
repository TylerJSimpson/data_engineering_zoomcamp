## Week 5 Homework

## Question 1. Install Spark and PySpark

Spark (and dependencies) installed as documented in the **Setup Spark** portion of my week 5 [README.MD](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/README.MD).  
Opened Jupyter Notebook:  
```bash
jupyter notebook
```
Import Pyspark:  
```python
import pyspark
```
Check version:  
```python
pyspark.__version__
```
Output: **3.3.1**

## Question 2. HVFHW February 2021

What's the size of the folder with results (in MB)?

Code can be found here [week5_homework.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/homework/week5_homework.ipynb).  

```bash
du -h
```
Output: **200M** ./06

## Question 3. Count records 

How many taxi trips were there on February 15?

Consider only trips that started on February 15.

Code can be found here [week5_homework.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/homework/week5_homework.ipynb).  

```python
spark.sql("""
SELECT  count(*)
FROM    fhvhv_2021_06 
WHERE   pickup_date = '2021-06-15'
;
""").show()
```

Output: **452470**  

## Question 4. Longest trip for each day

Now calculate the duration for each trip.

Trip starting on which day was the longest?  

Code can be found here [week5_homework.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/homework/week5_homework.ipynb).  

```python
spark.sql("""
SELECT  pickup_date,
        (unix_timestamp(dropoff_datetime)-unix_timestamp(pickup_datetime))/60
FROM    fhvhv_2021_06 
GROUP   BY 1,2
ORDER   BY 2 DESC
;
""").show()
```

Output: **2021-06-25**  

## Question 5. Most frequent `dispatching_base_num`

Now find the most frequently occurring `dispatching_base_num` 
in this dataset.

How many stages this spark job has?

> Note: the answer may depend on how you write the query,
> so there are multiple correct answers. 
> Select the one you have.  

Code can be found here [week5_homework.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/homework/week5_homework.ipynb).  

```python
spark.sql("""
SELECT  distinct(dispatching_base_num),
        count(dispatching_base_num)
FROM    fhvhv_2021_06 
GROUP   BY 1
ORDER   BY 2 DESC
;
""").show()
```
Output: **B02510**  

localhost:4040/jobs  
Stage 1 had 7 tasks.  
Stage 2 had 1 task (7 skipped)  

**New Question 5: User Interface**  
**Spark's UI is on local port 4040**  


## Question 6. Most common locations pair

Find the most common pickup-dropoff pair. 

For example:

"Jamaica Bay / Clinton East"

Enter two zone names separated by a slash

If any of the zone names are unknown (missing), use "Unknown". For example, "Unknown / Clinton East".  

Code can be found here [week5_homework.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/homework/week5_homework.ipynb).  

```python
spark.sql("""
SELECT  DISTINCT(CONCAT(PU_Zone, "/", DO_Zone)) AS PU_DO_Zone,
        COUNT(dispatching_base_num) AS Count
FROM    fhvhv_2021_06_result 
GROUP   BY 1
ORDER   BY 2 DESC
;
""").show(5,truncate=False)
```
Output: **East New York/East New York** with count 47926

**New Question 6: Most frequent pickup location zone**  
**Output: Crown Heights North with count 231279**  
```python
spark.sql("""
SELECT  DISTINCT(PU_Zone) AS PU_Zone,
        COUNT(PU_Zone) AS Count
FROM    fhvhv_2021_06_result 
GROUP   BY 1
ORDER   BY 2 DESC
;
""").show(5,truncate=False)
```
