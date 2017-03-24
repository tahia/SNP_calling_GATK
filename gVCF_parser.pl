#! /usr/bin/perl

#use warnings;
use strict;

use Data::Dumper;
use Getopt::Long;
use List::Util qw(first);


my ($vcf_file, $outputFile,$covmin,$help);

usage() if ( @ARGV < 1 or
	! GetOptions('help|?' => \$help, 
		'input=s' => \$vcf_file , 
		'output=s' => \$outputFile,
		'depthcovmin=i' =>\$covmin)
          #or defined $help 
);

sub usage
{
  print "Unknown option: @_\n" if ( @_ );
  print "usage: gVCF_parser.pl [--input or -i : INPUTFILE] [--output or -o : OUTPUTFILE] [-d --depthcovmin : minimum read depth] [--help|-?]\n";
  exit;
}

if ($help) {
	die usage;
}

die usage if ( !defined($outputFile) or !defined($vcf_file) );


if ( !defined($covmin)) {$covmin = 5;}




`rm -f $outputFile`;

my (@to_print,@marker_info,@marker_sam,$cov);

open(FILE, $vcf_file);
while(<FILE>)
	{chomp;
	#@print = ();
	#@marker_list = ();
	if($_ =~ /^#/) 
		{
		chomp;
		#get header lines for printing
		push @to_print, $_;
		}
	else {
		@marker_info = (split("\t", $_))[0..8];	
		@marker_sam = split(":",(split("\t", $_))[9]);
		# This is for only <NON_REF> where no QUAL score will be there for sixth field and format GT:DP:GQ:MIN_DP:PL
		if ($marker_info[5] eq ".") 
			{ 
			if (5 <= $marker_sam[1]) {push @to_print, $_; } # for printing
			else {next;}
			}
		# This is for ,<NON_REF> where we will find QUAL scores and format GT:AD:DP:GQ:PL:SB
		else 
			{
			if  ($marker_sam[2]>=5 &&  (split(",",$marker_sam[1]))[2] <1  )
				{
				if ( ($marker_sam[0] eq "./.") || ($marker_sam[0] eq "1/2") || ($marker_sam[0] eq "2/2") ) {next;}
				
				elsif ($marker_sam[0] eq "0/0" or $marker_sam[0] eq "1/1" ) {push @to_print, $_;} # for printing homo
				elsif ($marker_sam[0] eq "0/1")
					{
					my $nallele1 = (split(",",$marker_sam[1]))[0];
					my $nallele2 = (split(",",$marker_sam[1]))[1];
					my $rat = $nallele1/($nallele1+$nallele2);
					#{print "$rat\t$nallele1\t$nallele2\t$_\n";}
					if ( $rat > 0.25 && $rat < 0.75 )  {push @to_print, $_;} # for printing hetero in the range
					else #masking step
						{
						my $geno = $_;
						my $find = "0/1";
						if ( $rat <= 0.25) {my $replace = "1/1";$geno =~ s/$find/$replace/g;push @to_print, $_;} 
						else {my $replace = "0/0";$geno =~ s/$find/$replace/g;push @to_print, $_;}
						}

					}
				}
			}
	}

	}
close(FILE);



my $to_print_all_all = join("\n", @to_print);


open (FILEOUT,">>$outputFile");
print FILEOUT "$to_print_all_all\n";

close(FILEOUT);



