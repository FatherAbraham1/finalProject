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

my $source= param('source');
my $protocol = param('protocol');
my $info = param('info');
my $get_stmt = $cass->prepare( "SELECT * FROM source_protocol_info WHERE source='".$source."' AND protocol='".$protocol."' AND info ='".$info."'" )->get;

my ( undef, $result ) = $get_stmt->execute( [] )->get;
my $row = $result->row_hash(0);
my ($avg_len) = ($row->{avg_len});
my ($counts) = ($row->{counts});


#print Dumper(\$result->rows_hash);
print header, start_html(-title=>'hello CGI',-head=>Link({-rel=>'stylesheet',-href=>'/table.css',-type=>'text/css'}));

print div({-style=>'margin-left:110px;margin-right:auto;display:inline-block;box-shadow: 10px 10px 5px #888888;border:1px solid #000000;-moz-border-radius-bottomleft:9px;-webkit-border-bottom-left-radius:9px;border-bottom-left-radius:9px;-moz-border-radius-bottomright:9px;-webkit-border-bottom-right-radius:9px;border-bottom-right-radius:9px;-moz-border-radius-topright:9px;-webkit-border-top-right-radius:9px;border-top-right-radius:9px;-moz-border-radius-topleft:9px;-webkit-border-top-left-radius:9px;border-top-left-radius:9px;background:white'}, '&nbsp;Packets Report' . $counts. '&nbsp;');
print     p({-style=>"bottom-margin:10px"});
print table({-class=>'CSS_Table_Example', -style=>'width:60%;margin:auto;'},
	    Tr([td(['source','protocol','info','avg_len','counts']),
                td([$source,$protocol,$info,$avg_len,$counts])])),
    p({-style=>"bottom-margin:10px"})
    ;

print end_html;
