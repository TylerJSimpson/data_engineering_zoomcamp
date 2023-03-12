## Week 6 Homework 

In this homework, there will be two sections, the first session focus on theoretical questions related to Kafka 
and streaming concepts and the second session asks to create a small streaming application using preferred 
programming language (Python or Java).

### Question 1: 

**Please select the statements that are correct**
- **TRUE** Retention configuration ensures the messages not get lost over specific period of time.
- **TRUE** Group-Id ensures the messages are distributed to associated consumers
- **FALSE** Kafka Node is responsible to store topics
  - Topics are not stored in a specific node, they are distributed across a cluster
- **TRUE** Zookeeper is removed from Kafka cluster starting from version 4.0



### Question 2: 

**Please select the Kafka concepts that support reliability and availability**

- **TRUE** Topic Replication
  - Topics can be replicated across multiples nodes in a cluster providing fault tolerance and high availability  
- **TRUE** Topic Paritioning
  - Topics can be partitioned into multiple partitions and distributed across multiple nodes providing parallelism, scalability, fault tolerance, and high availability   
- **TRUE** Consumer Group Id
  - Multiple consumers can read from the same topic and can be grouped into consumer groups. Each consumer group gets a separate copy of the message in the topic and the messages are load-balanced across consumers providing fault tolerance and high availability  
- **FALSE** Ack All


### Question 3: 

**Please select the Kafka concepts that support scaling**  

- **TRUE** Topic Replication
  - Scaling can be done by adding more nodes to a cluster because topics are replicated across nodes in a cluster  
- **TRUE** Topic Paritioning
  - Scalability is inherent because topics are partitioned and distributed across nodes and more nodes can be added
- **TRUE** Consumer Group Id
  - Scalability is supported by the idea of being able to add more consumers to a consumer group to increase the rate of message consumption
- **FALSE** Ack All


### Question 4: 

**Please select the attributes that are good candidates for partitioning key. 
Consider cardinality of the field you have selected and scaling aspects of your application**  

Cardinality means that there are many unique values for that attribute. This ensures that data is evenly distributed across partitions and ensures partitions are not skewed.  
Generally unique identifiers and timestamps are good candidates for partitions.  
In this case I would lean towards vendor_id which would  allow for message distribution and load balancing.  
tpep_pickup_datetime and tpep_dropoff_datetime are also good candidates as they provide ordering of messages by time.  
- payment_type
- **vendor_id**
- passenger_count
- total_amount
- **tpep_pickup_datetime**
- **tpep_dropoff_datetime**


### Question 5: 

**Which configurations below should be provided for Kafka Consumer but not needed for Kafka Producer**

- **CONSUMER ONLY** Deserializer Configuration
  - Consuemrs need to know how to deserialize binary data from Kafka
- **CONSUMER ONLY** Topics Subscription
  - Consumers need to subscribe to 1+ topics to receive messages from Kafka
- **PRODUCER ONLY** Bootstrap Server
  - Producers need to know location of at least one node to connect to in order to send messages
- **CONSUMER ONLY** Group-Id
  - Consumers can be organized into consumer groups which have group-ids
- **CONSUMER ONLY** Offset
  - Consumers keep track of their position in each partition by maintaining an offset
- **PRODUCER ONLY** Cluster Key and Cluster-Secret
  - Producers may need to authenticate with Kafka nodes in a secure cluster that can use cluster key and cluster-secret


### Question 6:

Please implement a streaming application, for finding out popularity of PUlocationID across green and fhv trip datasets.
Please use the datasets [fhv_tripdata_2019-01.csv.gz](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv) 
and [green_tripdata_2019-01.csv.gz](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green)

PS: If you encounter memory related issue, you can use the smaller portion of these two datasets as well, 
it is not necessary to find exact number in the  question.

Your code should include following
1. Producer that reads csv files and publish rides in corresponding kafka topics (such as rides_green, rides_fhv)
2. Pyspark-streaming-application that reads two kafka topics
   and writes both of them in topic rides_all and apply aggregations to find most popular pickup location.


