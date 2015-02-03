#!/usr/bin/perl -w
# Program: cass_sample.pl
# Note: includes bug fixes for Net::Async::CassandraCQL 0.11 version

use strict;
use warnings;
use 5.10.0;

use IO::Async::Loop;
use Net::Async::CassandraCQL;
use Protocol::CassandraCQL qw( CONSISTENCY_ONE );
use Data::Dumper;
use CGI qw/:standard/;


 my $loop = IO::Async::Loop->new;

 my $cass = Net::Async::CassandraCQL->new(
    host => "localhost",
    keyspace => "wireshark", # changed dash to underscore in keyspace
    default_consistency => CONSISTENCY_ONE,
 );
 $loop->add( $cass );

 $cass->connect->get;

 my $get_stmt = $cass->prepare( "SELECT * FROM source_new;" )->get;

 my ( undef, $result ) = $get_stmt->execute( [] )->get;

#print Dumper(\$result->rows_hash);
print header, start_html('hello CGI'), Dumper(\$result->rows_hash), end_html;

