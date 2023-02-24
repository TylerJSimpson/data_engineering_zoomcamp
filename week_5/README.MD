# Week 5: Batch Processing - Spark
Placeholder

## Setup  

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

## PySpark

### Setup
Ensure that **port 8888** is open because we will use Jupyter to interact with Pyspark.  
**port 4040** can optionally be opened that will show all Spark jobs.  

Add PySpark to the PYTHONPATH.  
Please ensure the py4j below matches what is in ${SPARK_HOME}/python/lib  
```bash
export PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
export PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH"
```

### Testing
Run Jupyter.  
```bash
jupyter notebook
```
Use a token code generated to access in browser.  
See test jupyter notebook with pyspark [pyspark_test.ipynb](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_5/pyspark_test.ipynb).  

