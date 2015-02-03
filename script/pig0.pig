REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/apache-cassandra-2.0.11.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/apache-cassandra-thrift-2.0.11.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/jamm-0.2.5.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/libthrift-0.9.1.jar;
REGISTER ./cassandra-driver-core-2.0.5.jar;

PACKETS_ORIGIN = LOAD '/inputs/wireshark/small.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'NOCHANGE')as (number:long, time:double, source:chararray, destination, protocol, info, length:long);


--STORE PACKETS_ORIGIN INTO '/inputs/wireshark/pig0_output' USING PigStorage(',');


CASSANDRA_STRUCTURED  = FOREACH PACKETS_ORIGIN GENERATE TOTUPLE(TOTUPLE('number',number)), TOTUPLE(time,source,destination,protocol,info,length);
STORE CASSANDRA_STRUCTURED INTO 'cql://wireshark/source_new?output_query=update source_new set time%3D%3F,source%3D%3F,destination%3D%3F,protocol%3D%3F,info%3D%3F,length%3D%3F' USING org.apache.cassandra.hadoop.pig.CqlStorage();