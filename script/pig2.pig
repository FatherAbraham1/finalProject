REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/apache-cassandra-2.0.11.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/apache-cassandra-thrift-2.0.11.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/jamm-0.2.5.jar;
REGISTER /Users/Gaudi/apache-cassandra-2.0.11/lib/libthrift-0.9.1.jar;
REGISTER ./cassandra-driver-core-2.0.5.jar;

PACKETS_ORIGIN = LOAD '/inputs/wireshark/wireshark.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'NOCHANGE')as (number:int, time:double, source:chararray, destination, protocol, info, length:int);

PACKET0= FOREACH PACKETS_ORIGIN GENERATE number, time, SUBSTRING(source, 0, LAST_INDEX_OF(source,'.')) as source, destination, protocol, info, length;

PACKET1= FOREACH PACKET0 GENERATE number, time, source, destination, protocol, ((info matches '.*FIN, ACK.*') ? '[FIN]' : info) as info, length;

PACKET2= FOREACH PACKET1 GENERATE number, time, source, destination, protocol, ((info matches '.*SYN, ACK.*') ? '[SIN]' : info) as info, length;

PACKET3= FOREACH PACKET2 GENERATE number, time, source, destination, protocol, ((info matches '.*SYN.*') ? '[SYN]' : info) as info, length;

PACKET4= FOREACH PACKET3 GENERATE number, time, source, destination, protocol, ((info matches '.*ACK.*') ? '[ACK]' : info) as info, length;

PACKET5= FOREACH PACKET4 GENERATE number, time, source, destination, protocol, ((info matches '.*FIN.*') ? '[FIN, ACK]' : info) as info, length;

PACKET6= FOREACH PACKET5 GENERATE number, time, source, destination, protocol, ((info matches '.*SIN.*') ? '[SYN, ACK]' : info) as info, length;

DESTINATION = FILTER PACKET6 BY (source MATCHES '74.125.225.*');
DESTINATION_FROM_SOURCE = GROUP DESTINATION BY (source, protocol, info);
DESTINATION_FROM_SOURCE_COUNT = FOREACH DESTINATION_FROM_SOURCE GENERATE group.source AS source, group.protocol AS protocol, group.info AS info, COUNT($1) as counts:long, AVG($1.length) as avg_len;
OUT= ORDER DESTINATION_FROM_SOURCE_COUNT BY counts;





CASSANDRA_STRUCTURED  = FOREACH OUT GENERATE TOTUPLE(TOTUPLE('source',source), TOTUPLE('protocol',protocol), TOTUPLE('info',info)), TOTUPLE(counts,avg_len);
STORE CASSANDRA_STRUCTURED INTO 'cql://wireshark/source_protocol_info?output_query=update source_protocol_info set counts%3D%3F, avg_len%3D%3F' USING org.apache.cassandra.hadoop.pig.CqlStorage();

--STORE OUT INTO '/inputs/wireshark/pig2_output' USING PigStorage(',');
