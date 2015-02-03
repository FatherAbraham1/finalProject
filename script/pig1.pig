REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/apache-cassandra-2.0.11.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/apache-cassandra-thrift-2.0.11.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/jamm-0.2.5.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/libthrift-0.9.1.jar;
REGISTER ./cassandra-driver-core-2.0.5.jar;

PACKETS_ORIGIN = LOAD '/inputs/wireshark/wireshark.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'NOCHANGE')as (number:int, time:double, source:chararray, destination, protocol, info, length:int);
PACKETS= FOREACH PACKETS_ORIGIN GENERATE number, time, SUBSTRING(source, 0, LAST_INDEX_OF(source,'.')+1) as source, destination, protocol, info, length;
DESTINATION = FILTER PACKETS BY (destination == '192.168.0.102');
DESTINATION_FROM_SOURCE = GROUP DESTINATION BY source;
DESTINATION_FROM_SOURCE_BY_PROTOCOL = FOREACH DESTINATION_FROM_SOURCE GENERATE group AS source, COUNT($1) as counts:long;
OUT= ORDER DESTINATION_FROM_SOURCE_BY_PROTOCOL BY counts;


--STORE OUT INTO '/inputs/wireshark/pig1_output' USING PigStorage(',');


CASSANDRA_STRUCTURED  = FOREACH OUT GENERATE TOTUPLE(TOTUPLE('source',source)), TOTUPLE(counts);
STORE CASSANDRA_STRUCTURED INTO 'cql://wireshark/source_frequency?output_query=update source_frequency set counts%3D%3F' USING org.apache.cassandra.hadoop.pig.CqlStorage();