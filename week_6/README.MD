# Week 6: Stream Processing - Kafka
Overview of Kafka ... Placeholder

## Setup and Examples
Setting up Kafka using Docker and running producer/consumer examples in JSON and AVRO format and Pyspark.  

### Docker Setup

#### Start python environment and install requirements  
List conda environments:  
```bash
conda env list
```
Activate environment:  
```bash
conda activate {name}
```
navigate to [/python/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python)  
Install requirements:  
```bash
pip install -r requirements.txt
```

#### Build required images for running spark
Naviage to [python/docker/spark/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python/docker/spark)  
```bash
bash build.sh
```

#### Create Docker network and volume
Navigate to [python/docker/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python/docker)  
Create network:  
```bash
docker network  create kafka-spark-network
```  
Create volume:  
```bash
docker volume create --name=hadoop-distributed-file-system
```  
Check:  
```bash
docker network ls
```

#### Run services on Docker  
Navigate to [python/docker/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python/docker)   
```bash
docker-compose up -d
```
Check:  
```bash
docker ps
```

### JSON Example  
#### Kafka producer and consumer example using JSON format  
Navigate to [python/json_example/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python/json_example)  
Execute [producer.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_6/python/json_example/producer.py) to produce messages:  
```bash
python producer.py
```
Execute [consumer.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_6/python/json_example/consumer.py) to consume messages:  
```bash
python consumer.py
```
Notice the output matches the print statement in the consume_from_kafka function:  
```python
print(msg_val.key, msg_val.value)
```  
The consumer will continue running until exited.  

### AVRO Example  
#### Kafka producer and consumer example using AVRO format  
Navigate to [python/avro_example/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python/avro_example)  
Execute [producer.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_6/python/avro_example/producer.py) to produce messages:  
```bash
python producer.py
```
Execute [consumer.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_6/python/avro_example/consumer.py) to consume messages:  
```bash
python consumer.py
```

### Pyspark Example  
#### Kafka producer and consumer example using Pyspark  
Navigate to [python/streams-example/pyspark/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python/streams-example/pyspark)  
Execute [producer.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_6/python/streams-example/pyspark/producer.py) to produce messages:  
```bash
python producer.py
```
Execute [consumer.py](https://github.com/TylerJSimpson/data_engineering_zoomcamp/blob/main/week_6/python/streams-example/pyspark/consumer.py) to consume messages:  
```bash
python consumer.py
```
