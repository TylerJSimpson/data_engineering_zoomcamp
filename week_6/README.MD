# Week 6: Stream Processing - Kafka
Overview of Kafka ... Placeholder


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
Navigate to [python/json_example/](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_6/python/json_example)  


