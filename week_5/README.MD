# Week 5: Batch Processing - Spark
Overview of setting up Spark, Spark fundamentals/internals, and using PySpark and Spark SQL for processing.  

## Setup Spark  
This is an overview of setting up Spark on a Linux VM.  
### Install Java
Note that new version of JDK wont work with spark (current version 17+ in 2023).  
Make a new directory at ls ~ for spark and pre-requisites.  
```bash
mkdir spark
cd spark
```
Download the Java JDK.  
```bash
wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
```
Unpack JDK.  
```bash
tar xzfv openjdk-11.0.2_linux-x64_bin.tar.gz
```
Remove the gz file.  
```bash
rm openjdk-11.0.2_linux-x64_bin.tar.gz
```
Define JAVA_HOME which will be used by spark.
```bash
export JAVA_HOME="${HOME}/spark/jdk-11.0.2"
```
Add JAVA_HOME to PATH.  
```bash
export PATH="${JAVA_HOME}/bin:${PATH}"
```
Check that it worked properly.  
```bash
which java
java --version
```

### Install Spark
Recommendations:  
Package pre-built for Apache Hadoop 3.2 and later  
Download Spark.  
```bash
wget https://archive.apache.org/dist/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz
```
Unpack Spark.  
```bash
tar xzfv spark-3.3.1-bin-hadoop3.tgz
```
Remove the gz file.  
```bash
rm spark-3.3.1-bin-hadoop3.tgz
```
Define SPARK_HOME and define PATH.  
```bash
export SPARK_HOME="${HOME}/spark/spark-3.3.1-bin-hadoop3"
export PATH="${SPARK_HOME}/bin:${PATH}"
```
Check that it worked properly.  
```bash
spark-shell
```
Test with Scala code.  
```scala
val data = 1 to 10000
val distData = sc.parallelize(data)
distData.filter(_ < 10).collect()
```

### Add *_HOME to PATH in bashrc
```bash
nano .bashrc
```
Scroll to bottom and paste:  
export JAVA_HOME="${HOME}/spark/jdk-11.0.2"  
export PATH="${JAVA_HOME}/bin:${PATH}"  
export SPARK_HOME="${HOME}/spark/spark-3.3.1-bin-hadoop3"  
export PATH="${SPARK_HOME}/bin:${PATH}"  
Save for startup.  
```bash
source .bashrc
```

## PySpark & Spark SQL Overview

### Setup
Ensure that **port 8888** is open because we will use Jupyter to interact with Pyspark.  
**port 4040** can optionally be opened that will show all Spark jobs.  

Add PySpark to the PYTHONPATH add this to .bashrc as well.  
Please ensure the py4j below matches what is in ${SPARK_HOME}/python/lib  
```bash
export PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
export PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH"
```

Run Jupyter.  
```bash
jupyter notebook
```
Use a token code generated to access in browser.  
See jupyter notebook with pyspark [spark_01_test.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/spark_01_test.ipynb).  

### Introduction
Follow along in the notebook [spark_02_intro.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/spark_02_intro.ipynb)  
  
This notebook covers:
* Spark Introduction
* Spark Dataframes
* Spark SQL  
Note that prior to Spark SQL the following must be ran:  
Run script [download_data.sh](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/download_data.sh)  * Note that you will need to run this for TAXI_TYPE yellow & green and for YEAR 2020 & 2021  
Run notebook [taxi_schema.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/taxi_schema.ipynb)  

### Internals

#### Anatomy of a Spark Cluster
* A cluster contains a Master that receives the spark-submit from our computer. In our case this was via port 4040.  
* A cluster also contains executors which are the computers doing the execution.  
* Each executor pulls a partition of the dataframe (downloads it on the executor computer) and once the task/partition is complete it picks up another until they are all done.  
* Many times now the spark cluster and the lake where the dataframes are stored are in the same data center.  

#### Group By
Stage 1:  
* The executors do filtering (ie nothing before 2020) and then the group producing many intermediate results.  
Stage 2:  
* These intermediate results produced by each partition then must be grouped again.  
* This process is called reshuffling which is an external merge sort algorithm.  
* Records from the same partition are merged together by this method.  
Stage 3:  
* Partition records are grouped together to a single result.  

#### Joins
* First data is read and grouped as previously.  
* Each partition has a composite key dependent on the number of columns followed by the data.  
* Key, Data where if you are joining on 'hour' and 'zone' the key will combine 'hour' and 'zone'.  
* Reshuffling then happens (external merge sort algorithm). 1st partition receives all Key1, 2nd receives all Key2, etc.  
* Partition 1 can also receive Key4 etc as long as all matching keys are in a partition.  
* Now depending on the type of join partitions are filtered out.  
In the case of 1 table being very large and the other being very small respective to eachother:  
* Each partition of the large table goes to an executor 1 by 1 as previously.  
* For the small table a copy is created in EACH executor so no shuffling is needed.  


