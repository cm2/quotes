#! /usr/bin/env perl
#simple script to get quotes for various
#stocks

use warnings;
use strict;
use Finance::YahooQuote;
use XML::RSS;


#read the stock symbols from a file
#in which each symbol is on a new line
#and store in an array

my @companies = ();
open COMPANIES, "companies.txt" or die $!;
while(<COMPANIES>){
    push @companies, $_;
}
close COMPANIES;

my $err = "No companies requested.";
scalar @companies > 0 or die($err);

#process the stock symbols and write it
my @quotes = getquote(@companies);
my $output = '';

foreach (@quotes) {
    my @quote = @$_;
    $output  .= "$quote[0]: ";  #SYMBOL
    $output  .= "\$$quote[2] "; #PRICE
    $output  .= "$quote[5] ";   #CHANGE
    $output  .= "($quote[6])";  #% CHG
    $output  .= "\n";
}
print "$output\n";
