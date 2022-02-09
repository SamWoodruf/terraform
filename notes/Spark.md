---
title: Apache Spark
created: '2021-12-08T17:01:19.283Z'
modified: '2021-12-16T22:21:50.659Z'
---

# Apache Spark
# What is Spark?
- Apache Spark is a unified engine designed for large-scale distributed data processing, on premises in data centers or in the cloud.
- Spark provides in-memory storage for intermediate computations, making it much faster than Hadoop MapReduce. It incorporates libraries with composable APIs for machine learning (MLlib), SQL for interactive queries (Spark SQL), stream processing (Structured Streaming) for interacting with real-time data, and graph processing (GraphX).
# Spark Architecture
- Spark coordinates the execution of tasks on data across a **cluster** of computers.
  -  A **cluster**, or group, of computers, pools the resources of many machines together, giving us the ability to use all the cumulative resources as if they were a single computer.
- The cluster of machines that Spark will use to execute tasks is managed by a cluster manager like Spark’s standalone cluster manager, YARN, K8s, or Mesos. 
- We then submit Spark Applications to these cluster managers, which will grant resources to our application so that we can complete our work.
## Spark Applications
- A user program built on Spark using its APIs. It consists of a driver program and executors on the cluster.
### Driver
As the part of the Spark application responsible for instantiating a SparkSession, the Spark driver has multiple roles: it communicates with the cluster manager; it requests resources (CPU, memory, etc.) from the cluster manager for Spark’s executors (JVMs); and it transforms all the Spark operations into DAG computations, schedules them, and distributes their execution as tasks across the Spark executors. Once the resources are allocated, it communicates directly with the executors.
- The driver process is the heart of a Spark Application and maintains all relevant information during the lifetime of the application
- The driver process runs your main() function, sits on a node in the cluster, and is responsible for three things: 
  1. Maintaining information about the Spark Application;
  2. Responding to a user’s program or input; and analyzing, distributing, and
  3. Scheduling work across the executors 
### SparkSession
Through this one conduit, you can create JVM runtime parameters, define DataFrames and Datasets, read from data sources, access catalog metadata, and issue Spark SQL queries. SparkSession provides a single unified entry point to all of Spark’s functionality.
- An object that provides a point of entry to interact with underlying Spark functionality and allows programming Spark with its APIs. In an interactive Spark shell, the Spark driver instantiates a SparkSession for you, while in a Spark application, you create a SparkSession object yourself.
```
// Creating a SparkSession In Scala
import org.apache.spark.sql.SparkSession

// Build SparkSession
val spark = SparkSession
  .builder
  .appName("LearnSpark")
  .config("spark.sql.shuffle.partitions", 6)
  .getOrCreate()

// Use the session to read JSON 
val people = spark.read.json("...")

// Use the session to issue a SQL query
val resultsDF = spark.sql("SELECT city, pop, state, zip FROM table_name")
```
### Cluster Manager
The cluster manager is responsible for managing and allocating resources for the cluster of nodes on which your Spark application runs. Currently, Spark supports four cluster managers: the built-in standalone cluster manager, Apache Hadoop YARN, Apache Mesos, and Kubernetes.
### Spark Executors
A Spark executor runs on each worker node in the cluster. The executors communicate with the driver program and are responsible for executing tasks on the workers. In most deployments modes, only a single executor runs per node.
- This means that each executor is responsible for only two things: 
  1. Executing code assigned to it by the driver
  2. Reporting the state of the computation on that executor back to the driver node
- Spark employs a cluster manager that keeps track of the resources available.
- The driver process is responsible for executing the driver program’s commands across the executors to complete a given task.
### Partitions
- To allow every executor to perform work in parallel, Spark breaks up the data into chunks called partitions.
  - A partition is a collection of rows that sit on one physical machine in your cluster
- An important thing to note is that with DataFrames you do not (for the most part) manipulate partitions manually or individually. 
  - You simply specify high-level transformations of data in the physical partitions, and Spark determines how this work will actually execute on the cluster.
- Each executor's core gets a partition to work on
- You can programatically specify the amount of partitions that spark will allocate for a given dataset
### Job
- A parallel computation consisting of multiple tasks that gets spawned in response to a Spark action (e.g., save(), collect()).
- During interactive sessions with Spark shells, the driver converts your Spark application into one or more Spark jobs. It then transforms each job into a DAG. This, in essence, is Spark’s execution plan, where each node within a DAG could be a single or multiple Spark stages.
### Stage
- Each job gets divided into smaller sets of tasks called stages that depend on each other.
- As part of the DAG nodes, stages are created based on what operations can be performed serially or in parallel. Not all Spark operations can happen in a single stage, so they may be divided into multiple stages. Often stages are delineated on the operator’s computation boundaries, where they dictate data transfer among Spark executors.
### Task
- A single unit of work or execution that will be sent to a Spark executor.
- Each stage is comprised of Spark tasks (a unit of execution), which are then federated across each Spark executor; each task maps to a single core and works on a single partition of data. 
- As such, an executor with 16 cores can have 16 or more tasks working on 16 or more partitions in parallel, making the execution of Spark’s tasks exceedingly parallel!
### Deployment Modes
An attractive feature of Spark is its support for myriad deployment modes, enabling Spark to run in different configurations and environments. Because the cluster manager is agnostic to where it runs (as long as it can manage Spark’s executors and fulfill resource requests), Spark can be deployed in some of the most popular environments—such as Apache Hadoop YARN and Kubernetes—and can operate in different modes.
| Mode | Spark Driver | Spark Executor | Cluster Manager
| ----------- | ----------- | ----------- | ----------- |
| Local | Runs on a single JVM, like a laptop or single node | Runs on the same JVM as the driver | Runs on the same host
| Standalone | Can run on any node in the cluster	 | Each node in the cluster will launch its own executor JVM	| Can be allocated arbitrarily to any host in the cluster
| YARN (client) | Runs on a client, not part of the cluster	 | YARN’s NodeManager’s container	| YARN’s Resource Manager works with YARN’s Application Master to allocate the containers on NodeManagers for executors
| YARN (cluster) | Runs with the YARN Application Master	 | Same as YARN client mode	| Same as YARN client mode
| Kubernetes | Runs in a Kubernetes pod	 | Each worker runs within its own pod	| Kubernetes Master
# Spark APIs
Spark offers both structured and unstructured data APIs
## Structured APIs
- DataFrames and Datasets are (distributed) table-like collections with well-defined rows and columns. 
- Each column must have the same number of rows as all the other columns (although you can use null to specify the absence of a value) and each column has type information that must be consistent for every row in the collection. 
- To Spark, DataFrames and Datasets represent immutable, lazily evaluated plans that specify what operations to apply to data residing at a location to generate some output. 
- When we perform an action on a DataFrame, we instruct Spark to perform the actual transformations and return the result. These represent plans of how to manipulate rows and columns to compute the user’s desired result.
### Schemas
- A schema defines the column names and types of a DataFrame. You can define schemas manually or read a schema from a data source (often called schema on read). Schemas consist of types, meaning that you need a way of specifying what lies where.
### DataFrames
- A DataFrame is the most common Structured API and simply represents a table of data with rows and columns.
- The list that defines the columns and the types within those columns is called the schema.
  - You can think of a DataFrame as a spreadsheet with named columns.
    - The fundamental difference: a spreadsheet sits on one computer in one specific location, whereas a Spark DataFrame can span thousands of computers
- Untyped
  - To say that DataFrames are untyped is slightly inaccurate; they have types, but Spark maintains them completely and only checks whether those types line up to those specified in the schema at runtime.
  - To Spark (in Scala), DataFrames are simply Datasets of Type Row.
-  when you’re using DataFrames, you’re taking advantage of Spark’s optimized internal format. This format applies the same efficiency gains to all of Spark’s language APIs. 
#### DataFrame Operations
##### Using DataFrameReader and DataFrameWriter
Reading and writing are simple in Spark because of these high-level abstractions and contributions from the community to connect to a wide variety of data sources, including common NoSQL stores, RDBMSs, streaming engines such as Apache Kafka and Kinesis, and more.
- To get started, let’s read a large CSV file containing data on San Francisco Fire Department calls.1 As noted previously, we will define a schema for this file and use the DataFrameReader class and its methods to tell Spark what to do. Because this file contains 28 columns and over 4,380,660 records,2 it’s more efficient to define a schema than have Spark infer it:
```
// The spark.read.csv() function reads in the CSV file and returns a DataFrame of rows and named columns with the types dictated in the schema.
val fireSchema = StructType(Array(StructField("CallNumber", IntegerType, true),
                   StructField("UnitID", StringType, true),
                   StructField("IncidentNumber", IntegerType, true),
                   StructField("CallType", StringType, true), 
                   StructField("Location", StringType, true),
                   ...
                   ...
                   StructField("Delay", FloatType, true)))

// Read the file using the CSV DataFrameReader
val sfFireFile="/databricks-datasets/learning-spark-v2/sf-fire/sf-fire-calls.csv"
val fireDF = spark.read.schema(fireSchema)
  .option("header", "true")
  .csv(sfFireFile)
```
- To write the DataFrame into an external data source in your format of choice, you can use the DataFrameWriter interface. Like DataFrameReader, it supports multiple data sources. Parquet, a popular columnar format, is the default format; it uses snappy compression to compress the data. If the DataFrame is written as Parquet, the schema is preserved as part of the Parquet metadata. In this case, subsequent reads back into a DataFrame do not require you to manually supply a schema.

```
// In Scala to save as a Parquet file
val parquetPath = ...
fireDF.write.format("parquet").save(parquetPath)
```
```
// Alternatively, you can save it as a table, which registers metadata with the Hive metastore 
val parquetTable = ... // name of the table
fireDF.write.format("parquet").saveAsTable(parquetTable)
```
##### Transformations and Actions
###### Projections and Filters
A projection in relational parlance is a way to return only the rows matching a certain relational condition by using filters. In Spark, projections are done with the `select()` method, while filters can be expressed using the `filter()` or `where()` method. We can use this technique to examine specific aspects of our SF Fire Department data set:
```
val fewFireDF = fireDF
  .select("IncidentNumber", "AvailableDtTm", "CallType")
  .where($"CallType" =!= "Medical Incident")    
fewFireDF.show(5, false)
```
- What if we want to know how many distinct CallTypes were recorded as the causes of the fire calls? These simple and expressive queries do the job:
```
import org.apache.spark.sql.functions._
fireDF
  .select("CallType")
  .where(col("CallType").isNotNull)
  .agg(countDistinct('CallType) as 'DistinctCallTypes)
  .show()
// Output:
// +-----------------+
// |DistinctCallTypes|
// +-----------------+
// |               32|
// +-----------------+
```
- We can list the distinct call types in the data set using these queries:
```
fireDF
  .select("CallType")
  .where($"CallType".isNotNull())
  .distinct()
  .show(10, false)
// Output:
// +-----------------------------------+
// |CallType                           |
// +-----------------------------------+
// |Elevator / Escalator Rescue        |
// |Marine Fire                        |
// |Aircraft Emergency                 |
// |Confined Space / Structure Collapse|
// |Administrative                     |
// |Alarms                             |
// |Odor (Strange / Unknown)           |
// |Lightning Strike (Investigation)   |
// |Citizen Assist / Service Call      |
// |HazMat                             |
// +-----------------------------------+
```
###### Renaming, adding, and dropping columns
- You can selectively rename columns with the `withColumnRenamed()` method. For instance, let’s change the name of our Delay column to ResponseDelayedinMins and take a look at the response times that were longer than five minutes:
```
val newFireDF = fireDF.withColumnRenamed("Delay", "ResponseDelayedinMins")
newFireDF
  .select("ResponseDelayedinMins")
  .where($"ResponseDelayedinMins" > 5)
  .show(5, false)
// Output:
// +---------------------+
// |ResponseDelayedinMins|
// +---------------------+
// |5.233333             |
// |6.9333334            |
// |6.116667             |
// |7.85                 |
// |77.333336            |
// +---------------------+
// only showing top 5 rows
```
- `spark.sql.functions` has a set of to/from date/timestamp functions such as to_timestamp() and to_date() that we can use to convert data and time strings to their sql types:
```
val fireTsDF = newFireDF
  .withColumn("IncidentDate", to_timestamp(col("CallDate"), "MM/dd/yyyy"))
  .drop("CallDate")
  .withColumn("OnWatchDate", to_timestamp(col("WatchDate"), "MM/dd/yyyy"))
  .drop("WatchDate") 
  .withColumn("AvailableDtTS", to_timestamp(col("AvailableDtTm"), 
  "MM/dd/yyyy hh:mm:ss a"))
  .drop("AvailableDtTm") 

// Select the converted columns
fireTsDF
  .select("IncidentDate", "OnWatchDate", "AvailableDtTS")
  .show(5, false)
```
- Now that we have modified the dates, we can query using functions from spark.sql.functions like `dayofmonth()`, `dayofyear()`, and `dayofweek()` to explore our data further. 
- We could find out how many calls were logged in the last seven days, or we could see how many years’ worth of Fire Department calls are included in the data set with this query:
```
fireTsDF
  .select(year($"IncidentDate"))
  .distinct()
  .orderBy(year($"IncidentDate"))
  .show()
+------------------+
|year(IncidentDate)|
+------------------+
|              2000|
|              2001|
|              2002|
|              2003|
|              2004|
|              2005|
|              2006|
|              2007|
|              2008|
|              2009|
|              2010|
|              2011|
|              2012|
|              2013|
|              2014|
|              2015|
|              2016|
|              2017|
|              2018|
+------------------+
```
###### Aggregations
What if we want to know what the most common types of fire calls were, or what zip codes accounted for the most calls? These kinds of questions are common in data analysis and exploration.

A handful of transformations and actions on DataFrames, such as `groupBy()`, `orderBy()`, and `count()`, offer the ability to aggregate by column names and then aggregate counts across them.
```
// What were the most common types of fire calls?
fireTsDF
  .select("CallType")
  .where(col("CallType").isNotNull)
  .groupBy("CallType")
  .count()
  .orderBy(desc("count"))
  .show(10, false)

// Output:
// +-------------------------------+-------+
// |CallType                       |count  |
// +-------------------------------+-------+
// |Medical Incident               |2843475|
// |Structure Fire                 |578998 |
// |Alarms                         |483518 |
// |Traffic Collision              |175507 |
// |Citizen Assist / Service Call  |65360  |
// |Other                          |56961  |
// |Outside Fire                   |51603  |
// |Vehicle Fire                   |20939  |
// |Water Rescue                   |20037  |
// |Gas Leak (Natural and LP Gases)|17284  |
// +-------------------------------+-------+
```
###### Other command Dataframe operations
Along with all the others we’ve seen, the DataFrame API provides descriptive statistical methods like `min()`, `max()`, `sum()`, and `avg()`
```
import org.apache.spark.sql.{functions => F}
fireTsDF
  .select(F.sum("NumAlarms"), F.avg("ResponseDelayedinMins"), 
  F.min("ResponseDelayedinMins"), F.max("ResponseDelayedinMins"))
  .show()

// Output:
// +--------------+--------------------------+--------------------------+---------+
// |sum(NumAlarms)|avg(ResponseDelayedinMins)|min(ResponseDelayedinMins)|max(...) |
// +--------------+--------------------------+--------------------------+---------+
// |       4403441|         3.902170335891614|               0.016666668|1879.6167|
// +--------------+--------------------------+--------------------------+---------+

```
### Datasets
Spark 2.0 unified the DataFrame and Dataset APIs as Structured APIs with similar interfaces so that developers would only have to learn a single set of APIs. Datasets take on two characteristics: typed and untyped APIs
- Typed
  - Datasets check whether types conform to the specification at compile time.
- Datasets are only available to Java Virtual Machine (JVM)–based languages (Scala and Java) and we specify types with case classes or Java beans.
- Python and R are dynamically typed languages which is why datasets are not available for them
- To create a DataSet:
```
ex 1.
case class DeviceIoTData (battery_level: Long, c02_level: Long, 
val ds = spark.read
 .json("/databricks-datasets/learning-spark-v2/iot-devices/iot_devices.json")
 .as[DeviceIoTData]

ex 2.
case class DeviceTempByCountry(temp: Long, device_name: String, device_id: Long, 
  cca3: String)
val dsTemp = ds
  .filter(d => {d.temp > 25})
  .map(d => (d.temp, d.device_name, d.device_id, d.cca3))
  .toDF("temp", "device_name", "device_id", "cca3")
  .as[DeviceTempByCountry]
dsTemp.show(5, false)

+----+---------------------+---------+----+
|temp|device_name          |device_id|cca3|
+----+---------------------+---------+----+
|34  |meter-gauge-1xbYRYcj |1        |USA |
|28  |sensor-pad-4mzWkz    |4        |USA |
|27  |sensor-pad-6al7RTAobR|6        |USA |
|27  |sensor-pad-8xUD6pzsQI|8        |JPN |
|26  |sensor-pad-10BsywSYUF|10       |USA |
+----+---------------------+---------+----+
only showing top 5 rows

```
### Built-in Data Sources
Let’s get started by reading the data set into a temporary view:
```
// In Scala
import org.apache.spark.sql.SparkSession            
val spark = SparkSession
  .builder
  .appName("SparkSQLExampleApp")
  .getOrCreate()

// Path to data set 
val csvFile="/databricks-datasets/learning-spark-v2/flights/departuredelays.csv"

// Read and create a temporary view
// Infer schema (note that for larger files you may want to specify the schema)
val df = spark.read.format("csv")
  .option("inferSchema", "true")
  .option("header", "true")
  .load(csvFile)
// Create a temporary view
df.createOrReplaceTempView("us_delay_flights_tbl")
```
- Now that we have a temporary view, we can issue SQL queries using Spark SQL. These queries are no different from those you might issue against a SQL table in, say, a MySQL or PostgreSQL database. 
- The point here is to show that Spark SQL offers an ANSI:2003–compliant SQL interface, and to demonstrate the interoperability between SQL and DataFrames.
```
//First, we’ll find all flights whose distance is greater than 1,000 miles:
spark.sql("""SELECT distance, origin, destination 
FROM us_delay_flights_tbl WHERE distance > 1000 
ORDER BY distance DESC""").show(10)

// Output:
// +--------+------+-----------+
// |distance|origin|destination|
// +--------+------+-----------+
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// |4330    |HNL   |JFK        |
// +--------+------+-----------+
// only showing top 10 rows
//As the results show, all of the longest flights were between Honolulu (HNL) and New York (JFK).

//This query can also be expressed in the DF API in python like so:
// In Python
from pyspark.sql.functions import col, desc
(df.select("distance", "origin", "destination")
  .where(col("distance") > 1000)
  .orderBy(desc("distance"))).show(10)

```
```
// Next, we’ll find all flights between San Francisco (SFO) and Chicago (ORD) with at least a two-hour delay:

spark.sql("""SELECT date, delay, origin, destination 
FROM us_delay_flights_tbl 
WHERE delay > 120 AND ORIGIN = 'SFO' AND DESTINATION = 'ORD' 
ORDER by delay DESC""").show(10)

// Output: 
// +--------+-----+------+-----------+
// |date    |delay|origin|destination|
// +--------+-----+------+-----------+
// |02190925|1638 |SFO   |ORD        |
// |01031755|396  |SFO   |ORD        |
// |01022330|326  |SFO   |ORD        |
// |01051205|320  |SFO   |ORD        |
// |01190925|297  |SFO   |ORD        |
// |02171115|296  |SFO   |ORD        |
// |01071040|279  |SFO   |ORD        |
// |01051550|274  |SFO   |ORD        |
// |03120730|266  |SFO   |ORD        |
// |01261104|258  |SFO   |ORD        |
// +--------+-----+------+-----------+
// only showing top 10 rows
```
 - Let’s try a more complicated query where we use the CASE clause in SQL. In the following example, we want to label all US flights, regardless of origin and destination, with an indication of the delays they experienced: Very Long Delays (> 6 hours), Long Delays (2–6 hours), etc. We’ll add these human-readable labels in a new column called Flight_Delays:
```
spark.sql("""SELECT delay, origin, destination, 
              CASE
                  WHEN delay > 360 THEN 'Very Long Delays'
                  WHEN delay >= 120 AND delay <= 360 THEN 'Long Delays'
                  WHEN delay >= 60 AND delay < 120 THEN 'Short Delays'
                  WHEN delay > 0 and delay < 60 THEN 'Tolerable Delays'
                  WHEN delay = 0 THEN 'No Delays'
                  ELSE 'Early'
               END AS Flight_Delays
               FROM us_delay_flights_tbl
               ORDER BY origin, delay DESC""").show(10)

// Output:
// +-----+------+-----------+-------------+
// |delay|origin|destination|Flight_Delays|
// +-----+------+-----------+-------------+
// |333  |ABE   |ATL        |Long Delays  |
// |305  |ABE   |ATL        |Long Delays  |
// |275  |ABE   |ATL        |Long Delays  |
// |257  |ABE   |ATL        |Long Delays  |
// |247  |ABE   |DTW        |Long Delays  |
// |247  |ABE   |ATL        |Long Delays  |
// |219  |ABE   |ORD        |Long Delays  |
// |211  |ABE   |ATL        |Long Delays  |
// |197  |ABE   |DTW        |Long Delays  |
// |192  |ABE   |ORD        |Long Delays  |
// +-----+------+-----------+-------------+
// only showing top 10 rows
```
#### SQL Tables and Views
- Tables hold data. Associated with each table in Spark is its relevant metadata, which is information about the table and its data: the schema, description, table name, database name, column names, partitions, physical location where the actual data resides, etc. All of this is stored in a central metastore.
- Instead of having a separate metastore for Spark tables, Spark by default uses the Apache Hive metastore, located at /user/hive/warehouse, to persist all the metadata about your tables. However, you may change the default location by setting the Spark config variable `spark.sql.warehouse.dir` to another location, which can be set to a local or external distributed storage.
##### Managed Versus Unmanaged Tables
- Spark allows you to create two types of tables: managed and unmanaged. 
- For a managed table, Spark manages both the metadata and the data in the file store. 
  - This could be a local filesystem, HDFS, or an object store such as Amazon S3 or Azure Blob. 
- For an unmanaged table, Spark only manages the metadata, while you manage the data yourself in an external data source such as Cassandra.
- With a managed table, because Spark manages everything, a SQL command such as DROP TABLE table_name deletes both the metadata and the data. 
- With an unmanaged table, the same command will delete only the metadata, not the actual data. 
##### Creating SQL Databases Tables
- Tables reside within a database. By default, Spark creates tables under the default database. 
- To create your own database name, you can issue a SQL command from your Spark application or notebook. Let's create both a managed and an unmanaged table. To begin, we’ll create a database called learn_spark_db and tell Spark we want to use that database:
```
spark.sql("CREATE DATABASE learn_spark_db")
spark.sql("USE learn_spark_db")
// From this point, any commands we issue in our application to create tables will result in the tables being created in this database `learn_spark_db`.
```
###### Creating a managed table
To create a managed table within the database `learn_spark_db`, you can issue a SQL query like the following:
```
// In Scala/Python
spark.sql("CREATE TABLE managed_us_delay_flights_tbl (date STRING, delay INT,  
  distance INT, origin STRING, destination STRING)")
```
You can do the same thing using the DataFrame API like this:
```
# In Python
# Path to our US flight delays CSV file 
csv_file = "/databricks-datasets/learning-spark-v2/flights/departuredelays.csv"
# Schema as defined in the preceding example
schema="date STRING, delay INT, distance INT, origin STRING, destination STRING"
flights_df = spark.read.csv(csv_file, schema=schema)
flights_df.write.saveAsTable("managed_us_delay_flights_tbl")
```
###### Creating an umanaged table
- By contrast, you can create unmanaged tables from your own data sources—say, Parquet, CSV, or JSON files stored in a file store accessible to your Spark application.
- To create an unmanaged table from a data source such as a CSV file, in SQL use:
```
spark.sql("""CREATE TABLE us_delay_flights_tbl(date STRING, delay INT, 
  distance INT, origin STRING, destination STRING) 
  USING csv OPTIONS (PATH 
  '/databricks-datasets/learning-spark-v2/flights/departuredelays.csv')""")
```
- And within the DataFrame API use:
```
(flights_df
  .write
  .option("path", "/tmp/data/us_flights_delay")
  .saveAsTable("us_delay_flights_tbl"))
``````
##### Creating Views
- In addition to creating tables, Spark can create views on top of existing tables. 
- Views can be global (visible across all SparkSessions on a given cluster) or session-scoped (visible only to a single SparkSession), and they are temporary: they disappear after your Spark application terminates.
- Creating views has a similar syntax to creating tables within a database. Once you create a view, you can query it as you would a table. 
  - The difference between a view and a table is that views don’t actually hold the data; tables persist after your Spark application terminates, but views disappear.
- You can create a view from an existing table using SQL:
```
CREATE OR REPLACE GLOBAL TEMP VIEW us_origin_airport_SFO_global_tmp_view AS
  SELECT date, delay, origin, destination from us_delay_flights_tbl WHERE 
  origin = 'SFO';

CREATE OR REPLACE TEMP VIEW us_origin_airport_JFK_tmp_view AS
  SELECT date, delay, origin, destination from us_delay_flights_tbl WHERE 
  origin = 'JFK'
```
- Once you’ve created these views, you can issue queries against them just as you would against a table. Keep in mind that when accessing a global temporary view you must use the prefix `global_temp.<view_name>`, because Spark creates global temporary views in a global temporary database called `global_temp`. For example:
```
SELECT * FROM global_temp.us_origin_airport_SFO_global_tmp_view
```
- By contrast, you can access the normal temporary view without the global_temp prefix:
```
SELECT * FROM us_origin_airport_JFK_tmp_view
```
```
// In Scala/Python
spark.read.table("us_origin_airport_JFK_tmp_view")
// Or
spark.sql("SELECT * FROM us_origin_airport_JFK_tmp_view")
```
- You can also drop a view just like you would a table:
```
-- In SQL
DROP VIEW IF EXISTS us_origin_airport_SFO_global_tmp_view;
DROP VIEW IF EXISTS us_origin_airport_JFK_tmp_view
```
```
// In Scala/Python
spark.catalog.dropGlobalTempView("us_origin_airport_SFO_global_tmp_view")
spark.catalog.dropTempView("us_origin_airport_JFK_tmp_view")
```
- The difference between temporary and global temporary views being subtle, it can be a source of mild confusion among developers new to Spark. 
  - A temporary view is tied to a single SparkSession within a Spark application. 
  - In contrast, a global temporary view is visible across multiple SparkSessions within a Spark application. 
    - Yes, you can create multiple SparkSessions within a single Spark application—this can be handy, for example, in cases where you want to access (and combine) data from two different SparkSessions that don’t share the same Hive metastore configurations.
##### Viewing the Metadata
Spark manages the metadata associated with each managed or unmanaged table. This is captured in the Catalog, a high-level abstraction in Spark SQL for storing metadata. The Catalog’s functionality was expanded in Spark 2.x with new public methods enabling you to examine the metadata associated with your databases, tables, and views. Spark 3.0 extends it to use external catalog (which we briefly discuss in Chapter 12).

For example, within a Spark application, after creating the SparkSession variable spark, you can access all the stored metadata through methods like these:
```
spark.catalog.listDatabases()
spark.catalog.listTables()
spark.catalog.listColumns("us_delay_flights_tbl")
```
##### Caching SQL Tables
Like DataFrames, you can cache and uncache SQL tables and views. In Spark 3.0, in addition to other options, you can specify a table as LAZY, meaning that it should only be cached when it is first used instead of immediately:
```
-- In SQL
CACHE [LAZY] TABLE <table-name>
UNCACHE TABLE <table-name>
```
##### Reading Tables into DataFrames
- Often, data engineers build data pipelines as part of their regular data ingestion and ETL processes. They populate Spark SQL databases and tables with cleansed data for consumption by applications downstream.
- Let’s assume you have an existing database, learn_spark_db, and table, us_delay_flights_tbl, ready for use. Instead of reading from an external JSON file, you can simply use SQL to query the table and assign the returned result to a DataFrame:
```
// In Scala
val usFlightsDF = spark.sql("SELECT * FROM us_delay_flights_tbl")
val usFlightsDF2 = spark.table("us_delay_flights_tbl")
```
#### Data Sources for DataFrames and SQL Tables
##### DataFrameReader
`DataFrameReader` is the core construct for reading data from a data source into a DataFrame. It has a defined format and a recommended pattern for usage:
```
DataFrameReader.format(args).option("key", "value").schema(args).load()
```
Note that you can only access a `DataFrameReader` through a `SparkSession` instance. That is, you cannot create an instance of `DataFrameReader`. To get an instance handle to it, use:
```
SparkSession.read 
// or 
SparkSession.readStream
```
While read returns a handle to DataFrameReader to read into a DataFrame from a static data source, readStream returns an instance to read from a streaming source
| Method | Arguments | Description |
| ----------- | ----------- | ----------- |
| format() | "parquet", "csv", "txt", "json", "jdbc", "orc", "avro", etc. | If you don’t specify this method, then the default is Parquet or whatever is set in spark.sql.sources.default
| option() | ("mode", {PERMISSIVE or FAILFAST or DROPMALFORMED } ) ("inferSchema", {true or false}) ("path", "path_file_data_source") | A series of key/value pairs and options. The Spark documentation shows some examples and explains the different modes and their actions. The default mode is PERMISSIVE. The "inferSchema" and "mode" options are specific to the JSON and CSV file formats.
| schema() | DDL String or StructType, e.g., 'A INT, B STRING' or StructType(...) | For JSON or CSV format, you can specify to infer the schema in the option() method. Generally, providing a schema for any format makes loading faster and ensures your data conforms to the expected schema.
| load() | "/path/to/data/source" | The path to the data source. This can be empty if specified in option("path", "...").
```
// In Scala
// Use Parquet 
val file = """/databricks-datasets/learning-spark-v2/flights/summary-
  data/parquet/2010-summary.parquet"""
val df = spark.read.format("parquet").load(file) 
// Use Parquet; you can omit format("parquet") if you wish as it's the default
val df2 = spark.read.load(file)
// Use CSV
val df3 = spark.read.format("csv")
  .option("inferSchema", "true")
  .option("header", "true")
  .option("mode", "PERMISSIVE")
  .load("/databricks-datasets/learning-spark-v2/flights/summary-data/csv/*")
// Use JSON
val df4 = spark.read.format("json")
  .load("/databricks-datasets/learning-spark-v2/flights/summary-data/json/*")
```
##### DataFrameWriter
`DataFrameWriter` does the reverse of its counterpart: it saves or writes data to a specified built-in data source. Unlike with `DataFrameReader`, you access its instance not from a `SparkSession` but from the DataFrame you wish to save. It has a few recommended usage patterns:
```
DataFrameWriter.format(args)
  .option(args)
  .bucketBy(args)
  .partitionBy(args)
  .save(path)

DataFrameWriter.format(args).option(args).sortBy(args).saveAsTable(table)

// To get an instance handle, use:

DataFrame.write
// or 
DataFrame.writeStream
```
| Method | Arguments | Description |
| ----------- | ----------- | ----------- |
| format() | "parquet", "csv", "txt", "json", "jdbc", "orc", "avro", etc | If you don’t specify this method, then the default is Parquet or whatever is set in spark.sql.sources.default. | 
option() | ("mode", {append or overwrite or ignore, error or errorifexists} )("mode",{SaveMode.Overwrite or SaveMode.Append, SaveMode.Ignore,SaveMode.ErrorIfExists}) ("path", "path_to_write_to") | A series of key/value pairs and options. The Spark documentation shows some examples. This is an overloaded method. The default mode options are error or errorifexists and SaveMode.ErrorIfExists; they throw an exception at runtime if the data already exists.
| bucketBy() | (numBuckets, col, col..., coln) | The number of buckets and names of columns to bucket by. Uses Hive’s bucketing scheme on a filesystem.. | 
| save() | "/path/to/data/source"	 | The path to save to. This can be empty if specified in option("path", "...") | 
| saveAsTable() | "table_name"	 | The table to save to. | 
```
// In Scala
// Use JSON
val location = ... 
df.write.format("json").mode("overwrite").save(location)
```

### Structured API Execution
1. Write DataFrame/Dataset/SQL Code.
2. If valid code, Spark converts this to a Logical Plan.
    - This logical plan only represents a set of abstract transformations that do not refer to executors or drivers, it’s purely to convert the user’s set of expressions into the most optimized version. 
    - It does this by converting user code into an unresolved logical plan.
3. Spark transforms this Logical Plan to a Physical Plan, checking for optimizations along the way.
    - The physical plan, often called a Spark plan, specifies how the logical plan will execute on the cluster by generating different physical execution strategies and comparing them through a cost model
    - Physical planning results in a series of RDDs and transformations. 
      - This result is why you might have heard Spark referred to as a compiler—it takes queries in DataFrames, Datasets, and SQL and compiles them into RDD transformations for you.
4. Spark then executes this Physical Plan (RDD manipulations) on the cluster.
    - Upon selecting a physical plan, Spark runs all of this code over RDDs, the lower-level programming interface of Spark
```
// Basic dataframe creation in spark
val myRange = spark.range(1000).toDF("number")
```
### Spark Types
All basic spark types are subtypes of the class DataTypes, except for DecimalType

| Data Type | Value Assigned in Scala | API to instantiate |
| ----------- | ----------- | ----------- |
| ByteType | Byte | DataTypes.ByteType
| ShortType | Short | DataTypes.ShortType
| IntegerType | Int | DataTypes.IntegerType
| LongType | Long | DataTypes.LongType
| FloatType | Float | DataTypes.FloatType
| DoubleType | Double | DataTypes.DoubleType
| StringType | String | DataTypes.StringType
| BooleanType | Boolean | DataTypes.BooleanType
| DecimalType | java.math.BigDecimal | DecimalType

Structured data types in Spark

| Data Type | Value Assigned in Scala | API to instantiate |
| ----------- | ----------- | ----------- |
| BinaryType | Array[Byte] | DataTypes.BinaryType
| TimestampType | java.sql.Timestamp | DataTypes.Timestamp
| DateType | java.sql.Date | DataTypes.DateType
| ArrayType | scala.collection.Seq | DataTypes.createArrayType(ElementType)
| MapType | scala.collection.Map | DataTypes.createMapType(keyType, valueType)
| StructType | org.apache.spark.sql.Row | StructType(ArrayType[field Types])
| StructField | A value type corresponding to the type of this field | StructField(name, dataType, [nullable])

## Unstructured APIs
- The RDD is the most basic abstraction in Spark. There are three vital characteristics associated with an RDD:
  1. Dependencies
      - A list of dependencies that instructs Spark how an RDD is constructed with its inputs is required. When necessary to reproduce results, Spark can recreate an RDD from these dependencies and replicate operations on it. This characteristic gives RDDs resiliency.
  2. Partitions (with some locality information)
      - Partitions provide Spark the ability to split the work to parallelize computation on partitions across executors. In some cases—for example, reading from HDFS—Spark will use locality information to send work to executors close to the data. That way less data is transmitted over the network.
  3. Compute function: Partition => Iterator[T]
      - An RDD has a compute function that produces an Iterator[T] for the data that will be stored in the RDD.
      - The compute function (or computation) is opaque to Spark. That is, Spark does not know what you are doing in the compute function. Whether you are performing a join, filter, select, or aggregation, Spark only sees it as a lambda expression
        - Because it’s unable to inspect the computation or expression in the function, Spark has no way to optimize the expression—it has no comprehension of its intention.
## Lazy Evaluation
- Lazy evaulation means that Spark will wait until the very last moment to execute the graph of computation instructions. 
- In Spark, instead of modifying the data immediately when you express some operation, you build up a plan of transformations that you would like to apply to your source data.
  - By waiting until the last minute to execute the code, Spark compiles this plan from your raw DataFrame transformations to a streamlined physical plan that will run as efficiently as possible across the cluster.
## Transformations
- All transformations are evaluated lazily. Spark will not act on transformations until we call an action.
- In Spark, the core data structures are immutable, meaning they cannot be changed after they’re created. 
  - This might seem like a strange concept at first: if you cannot change it, how are you supposed to use it? 
    - To “change” a DataFrame, you need to instruct Spark how you would like to modify it to do what you want. These instructions are called transformations.
```
// This transformation finds all even numbers in a dataframe
val divisBy2 = myRange.where("number % 2 = 0")
```
- Transformations are the core of how you express your business logic using Spark. There are two types of transformations: 
  1. Those that specify narrow dependencies(1 to 1)
      - Transformations consisting of narrow dependencies are those for which each input partition will contribute to only one output partition
      - The where statement in the above code block specifies a narrow dependency, where only one partition contributes to at most one output partition
      - With narrow transformations, Spark will automatically perform an operation called pipelining
        - Meaning that if we specify multiple filters on DataFrames, they’ll all be performed in-memory.
      - `filter()` and `contains()` represent narrow transformations because they can operate on a single partition and produce the resulting output partition without any exchange of data across executors in the cluster.
  2. Those that specify wide dependencies(1 to N)
      - A wide dependency style transformation will have input partitions contributing to many output partitions. 
      - You will often hear this referred to as a shuffle whereby Spark will exchange partitions across the cluster.
        - When we perform a shuffle, Spark writes the results to disk
      - `groupBy()` or `orderBy()` instruct Spark to perform wide transformations, where data from other partitions is read in, combined, and written to disk
## Actions
- Transformations allow us to build up our logical transformation plan. To trigger the computation, we run an action. 
- An action instructs Spark to compute a result from a series of transformations.

| Transformations | Actions |
| ----------- | ----------- |
| orderBy() | show() |
| groupBy() | take() |
| filter() | count() |
| select() | collect() |
| join() | save() |

```
// The simplest action is count, which gives us the total number of records in the DataFrame:
divisBy2.count()
```
- There are three kinds of actions:
  1. Actions to view data in the console
  2. Actions to collect data to native objects in the respective language
  3. Actions to write to output data sources
## User-Defined Functions
While Apache Spark has a plethora of built-in functions, the flexibility of Spark allows for data engineers and data scientists to define their own functions too. These are known as user-defined functions (UDFs).

Here’s a simplified example of creating a Spark SQL UDF. Note that UDFs operate per session and they will not be persisted in the underlying metastore:
```
// In Scala
// Create cubed function
val cubed = (s: Long) => {
  s * s * s
}

// Register UDF
spark.udf.register("cubed", cubed)

// Create temporary view
spark.range(1, 9).createOrReplaceTempView("udf_test")
```
You can now use Spark SQL to execute either of these cubed() functions:
```
// In Scala/Python
// Query the cubed UDF
spark.sql("SELECT id, cubed(id) AS id_cubed FROM udf_test").show()

// Output:
// +---+--------+
// | id|id_cubed|
// +---+--------+
// |  1|       1|
// |  2|       8|
// |  3|      27|
// |  4|      64|
// |  5|     125|
// |  6|     216|
// |  7|     343|
// |  8|     512|
// +---+--------+
```
### Evaluation order and null checking in Spark SQL
- Spark SQL (this includes SQL, the DataFrame API, and the Dataset API) does not guarantee the order of evaluation of subexpressions. 
- For example, the following query does not guarantee that the s is NOT NULL clause is executed prior to the strlen(s) > 1 clause:
```
spark.sql("SELECT s FROM test1 WHERE s IS NOT NULL AND strlen(s) > 1")
```
Therefore, to perform proper null checking, it is recommended that you do the following:
  1. Make the UDF itself null-aware and do null checking inside the UDF.
  2. Use IF or CASE WHEN expressions to do the null check and invoke the UDF in a conditional branch.

## Higher-Order Functions in DataFrames and Spark SQL
Because complex data types are amalgamations of simple data types, it is tempting to manipulate them directly. There are two typical solutions for manipulating complex data types:
  - Exploding the nested structure into individual rows, applying some function, and then re-creating the nested structure
  - Building a user-defined function
### Higher-Order Functions in DataFrames and Spark SQL
In this nested SQL statement, we first `explode(values)`, which creates a new row (with the id) for each element (value) within values:
```
SELECT id, collect_list(value + 1) AS values
FROM  (SELECT id, EXPLODE(values) AS value
        FROM table) x
GROUP BY id
```
While `collect_list()` returns a list of objects with duplicates, the `GROUP BY` statement requires shuffle operations, meaning the order of the re-collected array isn’t necessarily the same as that of the original array. As `values` could be any number of dimensions (a really wide and/or really long array) and we’re doing a `GROUP BY`, this approach could be very expensive.
### Option 2: User-Defined Function
To perform the same task (adding 1 to each element in values), we can also create a UDF that uses `map()` to iterate through each element (value) and perform the addition operation:
```
// In Scala
def addOne(values: Seq[Int]): Seq[Int] = {
    values.map(value => value + 1)
}
val plusOneInt = spark.udf.register("plusOneInt", addOne(_: Seq[Int]): Seq[Int])
```
We could then use this UDF in Spark SQL as follows:
```
spark.sql("SELECT id, plusOneInt(values) AS values FROM table").show()
```
While this is better than using `explode()` and `collect_list()` as there won’t be any ordering issues, the serialization and deserialization process itself may be expensive. It’s also important to note, however, that `collect_list()` may cause executors to experience out-of-memory issues for large data sets, whereas using UDFs would alleviate these issues.

### Higher-Order Functions
In addition to the previously noted built-in functions, there are higher-order functions that take anonymous lambda functions as arguments. An example of a higher-order function is the following:
```
-- In SQL
transform(values, value -> lambda expression)
```
The `transform()` function takes an array (values) and anonymous function (lambda expression) as input. The function transparently creates a new array by applying the anonymous function to each element, and then assigning the result to the output array (similar to the UDF approach, but more efficiently).
```
// In Scala
// Create DataFrame with two rows of two arrays (tempc1, tempc2)
val t1 = Array(35, 36, 32, 30, 40, 42, 38)
val t2 = Array(31, 32, 34, 55, 56)
val tC = Seq(t1, t2).toDF("celsius")
tC.createOrReplaceTempView("tC")

// Show the DataFrame
tC.show()
```
With the preceding DataFrame you can run the following higher-order function queries:
#### transform()
The transform() function produces an array by applying a function to each element of the input array (similar to a map() function):
```
transform(array<T>, function<T, U>): array<U>
```
```
// In Scala/Python
// Calculate Fahrenheit from Celsius for an array of temperatures
spark.sql("""
SELECT celsius, 
 transform(celsius, t -> ((t * 9) div 5) + 32) as fahrenheit 
  FROM tC
""").show()

+--------------------+--------------------+
|             celsius|          fahrenheit|
+--------------------+--------------------+
|[35, 36, 32, 30, ...|[95, 96, 89, 86, ...|
|[31, 32, 34, 55, 56]|[87, 89, 93, 131,...|
+--------------------+--------------------+
```
#### filter()
`filter(array<T>, function<T, Boolean>): array<T>`
The filter() function produces an array consisting of only the elements of the input array for which the Boolean function is true:
```
// In Scala/Python
// Filter temperatures > 38C for array of temperatures
spark.sql("""
SELECT celsius, 
 filter(celsius, t -> t > 38) as high 
  FROM tC
""").show()

+--------------------+--------+
|             celsius|    high|
+--------------------+--------+
|[35, 36, 32, 30, ...|[40, 42]|
|[31, 32, 34, 55, 56]|[55, 56]|
+--------------------+--------+
```
#### exists()
`exists(array<T>, function<T, V, Boolean>): Boolean`
The exists() function returns true if the Boolean function holds for any element in the input array:
```
// In Scala/Python
// Is there a temperature of 38C in the array of temperatures
spark.sql("""
SELECT celsius, 
       exists(celsius, t -> t = 38) as threshold
  FROM tC
""").show()

+--------------------+---------+
|             celsius|threshold|
+--------------------+---------+
|[35, 36, 32, 30, ...|     true|
|[31, 32, 34, 55, 56]|    false|
+--------------------+---------+
```
#### reduce()
`reduce(array<T>, B, function<B, T, B>, function<B, R>)`
The reduce() function reduces the elements of the array to a single value by merging the elements into a buffer B using function<B, T, B> and applying a finishing function<B, R> on the final buffer:
```
// In Scala/Python
// Calculate average temperature and convert to F
spark.sql("""
SELECT celsius, 
       reduce(
          celsius, 
          0, 
          (t, acc) -> t + acc, 
          acc -> (acc div size(celsius) * 9 div 5) + 32
        ) as avgFahrenheit 
  FROM tC
""").show()

+--------------------+-------------+
|             celsius|avgFahrenheit|
+--------------------+-------------+
|[35, 36, 32, 30, ...|           96|
|[31, 32, 34, 55, 56]|          105|
+--------------------+-------------+
```
## Common DataFrames and Spark SQL Operations
Part of the power of Spark SQL comes from the wide range of DataFrame operations (also known as untyped Dataset operations) it supports. The list of operations is quite extensive and includes:
- Aggregate functions
- Collection functions
- Datetime functions
- Math functions
- Miscellaneous functions
- Non-aggregate functions
- Sorting functions
- String functions
- UDF functions
- Window functions

To perform these DataFrame operations, we’ll first prepare some data. In the following code snippet, we:
1. Import two files and create two DataFrames, one for airport (airportsna) information and one for US flight delays (departureDelays).
2. Using expr(), convert the delay and distance columns from STRING to INT.
3. Create a smaller table, foo, that we can focus on for our demo examples; it contains only information on three flights originating from Seattle (SEA) to the destination of San Francisco (SFO) for a small time range.
```
// In Scala
import org.apache.spark.sql.functions._

// Set file paths
val delaysPath = 
  "/databricks-datasets/learning-spark-v2/flights/departuredelays.csv"
val airportsPath = 
  "/databricks-datasets/learning-spark-v2/flights/airport-codes-na.txt"

// Obtain airports data set
val airports = spark.read
  .option("header", "true")
  .option("inferschema", "true")
  .option("delimiter", "\t")
  .csv(airportsPath)
airports.createOrReplaceTempView("airports_na")

// Obtain departure Delays data set
val delays = spark.read
  .option("header","true")
  .csv(delaysPath)
  .withColumn("delay", expr("CAST(delay as INT) as delay"))
  .withColumn("distance", expr("CAST(distance as INT) as distance"))
delays.createOrReplaceTempView("departureDelays")

// Create temporary small table
val foo = delays.filter(
  expr("""origin == 'SEA' AND destination == 'SFO' AND 
      date like '01010%' AND delay > 0"""))
foo.createOrReplaceTempView("foo")
```
The departureDelays DataFrame contains data on >1.3M flights while the foo DataFrame contains just three rows with information on flights from SEA to SFO for a specific time range, as noted in the following output:
```
// Scala/Python
spark.sql("SELECT * FROM airports_na LIMIT 10").show()

+-----------+-----+-------+----+
|       City|State|Country|IATA|
+-----------+-----+-------+----+
| Abbotsford|   BC| Canada| YXX|
|   Aberdeen|   SD|    USA| ABR|
|    Abilene|   TX|    USA| ABI|
|      Akron|   OH|    USA| CAK|
|    Alamosa|   CO|    USA| ALS|
|     Albany|   GA|    USA| ABY|
|     Albany|   NY|    USA| ALB|
|Albuquerque|   NM|    USA| ABQ|
| Alexandria|   LA|    USA| AEX|
|  Allentown|   PA|    USA| ABE|
+-----------+-----+-------+----+

spark.sql("SELECT * FROM departureDelays LIMIT 10").show()

+--------+-----+--------+------+-----------+
|    date|delay|distance|origin|destination|
+--------+-----+--------+------+-----------+
|01011245|    6|     602|   ABE|        ATL|
|01020600|   -8|     369|   ABE|        DTW|
|01021245|   -2|     602|   ABE|        ATL|
|01020605|   -4|     602|   ABE|        ATL|
|01031245|   -4|     602|   ABE|        ATL|
|01030605|    0|     602|   ABE|        ATL|
|01041243|   10|     602|   ABE|        ATL|
|01040605|   28|     602|   ABE|        ATL|
|01051245|   88|     602|   ABE|        ATL|
|01050605|    9|     602|   ABE|        ATL|
+--------+-----+--------+------+-----------+

spark.sql("SELECT * FROM foo").show()

+--------+-----+--------+------+-----------+
|    date|delay|distance|origin|destination|
+--------+-----+--------+------+-----------+
|01010710|   31|     590|   SEA|        SFO|
|01010955|  104|     590|   SEA|        SFO|
|01010730|    5|     590|   SEA|        SFO|
+--------+-----+--------+------+-----------+
```
In the following sections, we will execute union, join, and windowing examples with this data.
### Unions
A common pattern within Apache Spark is to union two different DataFrames with the same schema together. This can be achieved using the union() method:
```
// Scala
// Union two tables
val bar = delays.union(foo)
bar.createOrReplaceTempView("bar")
bar.filter(expr("""origin == 'SEA' AND destination == 'SFO'
AND date LIKE '01010%' AND delay > 0""")).show()
```
The bar DataFrame is the union of foo with delays. Using the same filtering criteria results in the bar DataFrame, we see a duplication of the foo data, as expected
```
-- In SQL
spark.sql("""
SELECT * 
  FROM bar 
 WHERE origin = 'SEA' 
   AND destination = 'SFO' 
   AND date LIKE '01010%' 
   AND delay > 0
""").show()

+--------+-----+--------+------+-----------+
|    date|delay|distance|origin|destination|
+--------+-----+--------+------+-----------+
|01010710|   31|     590|   SEA|        SFO|
|01010955|  104|     590|   SEA|        SFO|
|01010730|    5|     590|   SEA|        SFO|
|01010710|   31|     590|   SEA|        SFO|
|01010955|  104|     590|   SEA|        SFO|
|01010730|    5|     590|   SEA|        SFO|
+--------+-----+--------+------+-----------+
```
### Joins
A common DataFrame operation is to join two DataFrames (or tables) together. By default, a Spark SQL join is an `inner join`, with the options being `inner`, `cross`, `outer`, `full`, `full_outer`, `left`, `left_outer`, `right`, `right_outer`, `left_semi`, and `left_anti`. 
```
// In Scala
foo.join(
  airports.as('air), 
  $"air.IATA" === $"origin"
).select("City", "State", "date", "delay", "distance", "destination").show()

+-------+-----+--------+-----+--------+-----------+
|   City|State|    date|delay|distance|destination|
+-------+-----+--------+-----+--------+-----------+
|Seattle|   WA|01010710|   31|     590|        SFO|
|Seattle|   WA|01010955|  104|     590|        SFO|
|Seattle|   WA|01010730|    5|     590|        SFO|
+-------+-----+--------+-----+--------+-----------+
```
```
-- In SQL
spark.sql("""
SELECT a.City, a.State, f.date, f.delay, f.distance, f.destination 
  FROM foo f
  JOIN airports_na a
    ON a.IATA = f.origin
""").show()
```


