#/usr/bin/perl
# Copyright (c) 2001-2003 International Business Machines
# Corporation and others. All Rights Reserved.

####################################################################################
# filterRFC3454.pl:
# This tool filters the RFC-3454 txt file for StringPrep tables and creates a table
# to be used in NamePrepProfile
#
# Author: Ram Viswanadha
#        
####################################################################################

use File::Find;
use File::Basename;
use IO::File;
use Cwd;
use File::Copy;
use Getopt::Long;
use File::Path;
use File::Copy;

$copyright = "#################\n# This file was generated RFC 3454 (http://www.ietf.org/rfc/rfc3454.txt) with \n# Copyright (C) The Internet Society (2002).  All Rights Reserved. \n###################\n\n";
$warning = "###################\n# WARNING: This table is generated by filterRFC3454.pl tool. DO NOT EDIT \n###################\n\n";
#run the program)
main();

#---------------------------------------------------------------------
# The main program

sub main(){
  GetOptions(
           "--sourcedir=s" => \$sourceDir,
           "--destdir=s" => \$destDir,
           "--src-filename=s" => \$srcFileName,
           "--dest-filename=s" => \$destFileName,
           "--A1"  => \$a1,
           "--B1"  => \$b1,
           "--B2"  => \$b2,
		   "--B3"  => \$b3,
           "--C11" => \$c11,
           "--C12" => \$c12,
           "--C21" => \$c21,
           "--C22" => \$c22,
           "--C3"  => \$c3,
           "--C4"  => \$c4,
           "--C5"  => \$c5,
           "--C6"  => \$c6,
           "--C7"  => \$c7,
           "--C8"  => \$c8,
           "--C9"  => \$c9,
           "--ldh-chars" => \$writeLDHChars,
           "--iscsi" => \$writeISCSIChars,
           );
  usage() unless defined $sourceDir;
  usage() unless defined $destDir;
  usage() unless defined $srcFileName;
  usage() unless defined $destFileName;

  $infile = $sourceDir."/".$srcFileName;
  $inFH = IO::File->new($infile,"r")
            or die  "could not open the file $infile for reading: $! \n";
  $outfile = $destDir."/".$destFileName;

  unlink($outfile);
  $outFH = IO::File->new($outfile,"a")
            or die  "could not open the file $outfile for writing: $! \n";
  print $outFH  $copyright;
  print $outFH  $warning;
  close($outFH);

  if(defined $b2 && defined $b3){
      die "ERROR: --B2 and --B3 are both specified\!\n";
  }

  while(defined ($line=<$inFH>)){
      next unless $line=~ /Start\sTable/;
      if($line =~ /A.1/){
            createUnassignedTable($inFH,$outfile);
      }
      if($line =~ /B.1/ && defined $b1){
            createMapToNothing($inFH,$outfile);
      }
      if($line =~ /B.2/ && defined $b2){
            createCaseMapNorm($inFH,$outfile);
      }
      if($line =~ /B.3/ && defined $b3){
            createCaseMapNoNorm($inFH,$outfile);
      }
      if($line =~ /C.1.1/ && defined $c11 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.1.2/ && defined $c12 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.2.1/ && defined $c21 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.2.2/ && defined $c22 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.3/ && defined $c3 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.4/ && defined $c4 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.5/ && defined $c5 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.6/ && defined $c6 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.7/ && defined $c7 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.8/ && defined $c8 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
      if($line =~ /C.9/ && defined $c9 ){
            createProhibitedTable($inFH,$outfile,$line);
      }
  }
  if( defined $writeISCSIChars){
      create_iSCSIExtraProhibitedTable($inFH, $outfile);
  }
  close($inFH);
}

#-----------------------------------------------------------------------
sub readPrint{
    local ($inFH, $outFH,$comment, $table) = @_;
    $count = 0;
    print $outFH $comment."\n";
    while(defined ($line = <$inFH>)){
        next if $line =~ /Hoffman\s\&\sBlanchet/;  # ignore heading
        next if $line =~ /RFC\s3454/; # ignore heading
        next if $line =~ /\f/;  # ignore form feed
        next if $line eq "\n";  # ignore blank lines
        # break if "End Table" is found
        if( $line =~ /End\sTable/){
            print $outFH "\n# Total code points $count\n\n";
            return;
        }
        if($print==1){
            print $line;
        }
        $line =~ s/-/../;
        $line =~ s/^\s+//;
        if($line =~ /\;/){
        }else{
            $line =~ s/$/;/;
        }
        if($table =~ /A/ ){
            ($code, $noise) = split /;/ , $line;
            $line = $code."; ; UNASSIGNED\n";
        }elsif ( $table =~ /B\.1/ ){
            $line =~ s/Map to nothing/MAP/;
        }elsif ( $table =~ /B\.[23]/ ){
            $line =~ s/Case map/MAP/;
            $line =~ s/Additional folding/MAP/;
        }elsif ( $table =~ /C/ ) {
            ($code, $noise) = split /;/ , $line;   
            $line = $code."; ; PROHIBITED\n";
        }
        if($line =~ /\.\./){
            ($code, $noise) = split /;/ , $line;
            ($startStr, $endStr ) = split /\.\./, $code;
            $start = atoi($startStr);
            $end   = atoi($endStr);
            #print $start."     ".$end."\n";
            while($start <= $end){
                $count++;
                $start++;
            }
        }else{
              $count++;
        }
        print $outFH $line;
    }
}
#-----------------------------------------------------------------------
sub atoi {
    my $t;
    foreach my $d (split(//, shift())) {
        $t = $t * 16 + $d;
    }
    return $t;
}
#-----------------------------------------------------------------------
sub createUnassignedTable{
    ($inFH,$outfile) = @_;
    $outFH = IO::File->new($outfile,"a")
            or die  "could not open the file $outfile for writing: $! \n";
    $comment = "# This table contains code points from Table A.1 from RFC 3454\n";
    readPrint($inFH,$outFH, $comment, "A");
    close($outFH);
}
#-----------------------------------------------------------------------
sub createMapToNothing{
    ($inFH,$outfile) = @_;
    $outFH = IO::File->new($outfile,"a")
            or die  "could not open the file $outfile for writing: $! \n";
    $comment = "# This table contains code points from Table B.1 from RFC 3454\n";
    readPrint($inFH,$outFH,$comment, "B.1");
    close($outFH);
}
#-----------------------------------------------------------------------
sub createCaseMapNorm{
    ($inFH,$outfile) = @_;
    $outFH = IO::File->new($outfile,"a")
            or die  "could not open the file $outfile for writing: $! \n";
    $comment = $warning."# This table contains code points from Table B.2 from RFC 3454\n";
    readPrint($inFH,$outFH,$comment, "B.2");
    close($outFH);
}
#-----------------------------------------------------------------------
sub createCaseMapNoNorm{
    ($inFH,$outfile) = @_;
    $outFH = IO::File->new($outfile,"a")
            or die  "could not open the file $outfile for writing: $! \n";
    $comment = $warning."# This table contains code points from Table B.3 from RFC 3454\n";
    readPrint($inFH,$outFH,$comment, "B.3");
    close($outFH);
}
#-----------------------------------------------------------------------
sub createProhibitedTable{
    ($inFH,$outfile,$line) = @_;
    $line =~ s/Start//;
    $line =~ s/-//g;
    $comment = "# code points from $line";

    $outFH = IO::File->new($outfile, "a")
            or die  "could not open the file $outfile for writing: $! \n";
    readPrint($inFH,$outFH,$comment, "C");
    close($outFH);
}

#-----------------------------------------------------------------------
sub create_iSCSIExtraProhibitedTable{
    ($inFH,$outfile,$line) = @_;
    $comment ="# Additional prohibitions from draft-ietf-ips-iscsi-string-prep-06.txt\n";

    $outFH = IO::File->new($outfile, "a")
            or die  "could not open the file $outfile for writing: $! \n";
    print $outFH $comment;
    print $outFH "0021..002C; ; PROHIBITED\n";
    print $outFH "002F; ; PROHIBITED\n";
    print $outFH "003B..0040; ; PROHIBITED\n";
    print $outFH "005B..0060; ; PROHIBITED\n";
    print $outFH "007B..007E; ; PROHIBITED\n";
    print $outFH "3002; ; PROHIBITED\n";
    print $outFH "\n# Total code points 30\n";
    close($outFH);
}
#-----------------------------------------------------------------------
sub usage {
    print << "END";
Usage:
filterRFC3454.pl
Options:
        --sourcedir=<directory>
        --destdir=<directory>
        --src-filename=<name of RFC file>
        --dest-filename=<name of destination file>
        --A1             Generate data for table A.1
        --B1             Generate data for table B.1
        --B2             Generate data for table B.2
        --B3             Generate data for table B.3
        --C11            Generate data for table C.1.1
        --C12            Generate data for table C.1.2
        --C21            Generate data for table C.2.1
        --C22            Generate data for table C.2.2
        --C3             Generate data for table C.3
        --C4             Generate data for table C.4
        --C5             Generate data for table C.5
        --C6             Generate data for table C.6
        --C7             Generate data for table C.7
        --C8             Generate data for table C.8
        --C9             Generate data for table C.9
        --iscsi          Generate data for extra prohibited iSCSI chars

Note, --B2 and --B3 are mutually exclusive.

e.g.: filterRFC3454.pl --sourcedir=. --destdir=./output --src-filename=rfc3454.txt  --dest-filename=NamePrepProfile.txt --A1 --B1 --B2 --C12 --C22 --C3 --C4 --C5 --C6 --C7 --C8 --C9

filterRFC3454.pl filters the RFC file and creates String prep table files.
The RFC text can be downloaded from ftp://ftp.rfc-editor.org/in-notes/rfc3454.txt

END
  exit(0);
}


