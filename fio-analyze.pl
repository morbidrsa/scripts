#!/usr/bin/perl
# Copyright (C) 2015 - Johannes Thumshirn <jthumshirn@suse.de>
# Analyze a driectory full of fio reports and print avg and stddev for read
# and write IOPS and throughput.

use strict;
use warnings;

my $reportdir = '.';
my @read_iops;
my @read_bw;
my @write_iops;
my @write_bw;
my $rbunit;
my $wbunit;

sub average {
        my (@values) = @_;

        my $count = scalar @values;
        my $total = 0;
        $total += $_ for @values;

        return $count ? $total / $count : 0;
}

sub std_dev {
        my ($average, @values) = @_;

        my $count = scalar @values;
        my $std_dev_sum = 0;
        $std_dev_sum += ($_ - $average) ** 2 for @values;

        return $count ? sqrt($std_dev_sum / $count) : 0;
}

if (defined $ARGV[0]) {
	$reportdir = $ARGV[0];
}


opendir(my $content, "$reportdir") 
	or die("Can't open reports directory $reportdir: $!");
my @report_files = readdir($content);
closedir($content);

foreach my $report_file (@report_files) {
	next if $report_file eq ".." || $report_file eq "..";

	my $report;
	open($report, $reportdir . $report_file)
		or die("Can't open report file ". $reportdir . "/" . 
			$report_file . ": $!");

	while(<$report>) {
		my $line = $_;

		if ($line =~ /^\s+read/) {
			my $iops = $1 if $line =~ m/iops=([0-9]+),/;
			my $bw = $1 if $line =~ m/bw=([0-9]+[ KMG]B\/s),/;

			my $bval = $1 if $bw =~ m/([0-9]+)/;
			$rbunit = $1 if $bw =~ m/[0-9]+([ KMG]B\/s)/;

			push(@read_iops, $iops);
			push(@read_bw, $bval);
			
		}

		if ($line =~ /^\s+write/) {
			my $iops = $1 if $line =~ m/iops=([0-9]+),/;
			my $bw = $1 if $line =~ m/bw=([0-9]+[ KMG]B\/s),/;

			my $bval = $1 if $bw =~ m/([0-9]+)/;
			$wbunit = $1 if $bw =~ m/[0-9]+([ KMG]B\/s)/;

			push(@write_iops, $iops);
			push(@write_bw, $bval);
		}
	}
}


my $avg_read_iops = average(@read_iops);
my $read_iops_dev = std_dev($avg_read_iops, @read_iops);
printf "Read  IOPS: avg=%.4f, std. dev=%.4f\n", $avg_read_iops, $read_iops_dev;

my $avg_read_bw = average(@read_bw);
my $read_bw_dev = std_dev($avg_read_bw, @read_bw);
printf "Read    BW: avg=%.4f%s, std. dev=%.4f\n",
	$avg_read_bw, $rbunit, $read_bw_dev;

my $avg_write_iops = average(@write_iops);
my $write_iops_dev = std_dev($avg_write_iops, @write_iops);
printf "Write IOPS: avg=%.4f, std. dev=%.4f\n", 
	$avg_write_iops, $write_iops_dev;

my $avg_write_bw = average(@write_bw);
my $write_bw_dev = std_dev($avg_write_bw, @write_bw);
printf "Write   BW: avg=%.4f%s, std. dev=%.4f\n", 
	$avg_write_bw, $wbunit, $write_bw_dev;
