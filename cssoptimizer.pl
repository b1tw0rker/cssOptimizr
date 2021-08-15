#!/usr/bin/perl

use strict;
use warnings;

### register vars
###
###
my $row;
my @split;
my @dot_selektoren;
my @gatter_selektoren;
my @u_dot_selektoren;
my @u_gatter_selektoren;
my $zeile;
my $no001;
my $no002;
my $no003;
my $no004;
my @hit;

### some usefull vars
###
###
my $p       = "/root/webmin-1.970/virtualx";                         ## pfad to check
my $f       = "pl,cgi,html,php";                                     ## search selectors in these file types only.
my $cssfile = "/root/webmin-1.970/virtualx/assets/css/style.css";    ## the css file we wanna optimize.

### test
###
###
if ( !-e $cssfile ) {
    print "Could not find file: $cssfile\n";
    exit;
}

### open file and push to array
###
###
open( my $CSS, "<", $cssfile );
while (<$CSS>) {

    chomp($_);

    ### check for dot selectors
    if (/^\./) {
        $row = $_;

        if (/\ \{/) {
            @split = split( /\ \{/, $row );    ## del _{
            $row   = $split[0];
        }

        if (/\{/) {
            @split = split( /\{/, $row );      ## del {
            $row   = $split[0];
        }

        if (/\:/) {
            @split = split( /\:/, $row );      ## del :
            $row   = $split[0];
        }

        if (/\,/) {
            $row = substr $row, -1;
        }

        if (/^\./) {
            $row = substr( $row, 1 );          # erstes zeichen (dot .) abschneiden
        }

        push @dot_selektoren, $row;
        undef($row);

    }

    ## check for # selector
    if (/^\#/) {
        $row = $_;

        if (/\ \{/) {
            @split = split( /\ \{/, $row );    ## del _{
            $row   = $split[0];
        }

        if (/\{/) {
            @split = split( /\{/, $row );      ## del {
            $row   = $split[0];
        }

        if (/\:/) {
            @split = split( /\:/, $row );      ## del :
            $row   = $split[0];
        }

        if (/\,/) {
            $row = substr $row, -1;
        }

        if (/^\#/) {
            $row = substr( $row, 1 );          # erstes zeichen . # abschneiden
        }

        push @gatter_selektoren, $row;
        undef($row);
    }

}
close($CSS);

### make it unique
###
###
@u_dot_selektoren    = uniq(@dot_selektoren);
@u_gatter_selektoren = uniq(@gatter_selektoren);

### print array zeilweise
###
###
foreach $zeile (@u_dot_selektoren) {

    #my $e = skywalker($zeile,$p,$f);
    # grep -i -r -s -h -o --include=*.{pl,cgi,html,php} "class=[\\'\"].*balken." /root/webmin-1.970/virtualx
    my $cmd = 'grep -i -r -s -h -o --include=*.{' . $f . '} "class=[\\\'\"].*' . $zeile . '." ' . $p . '';
    @hit = qx{$cmd};
    my $e = scalar @hit;

    if ( $e == "0" ) {
        print "$zeile\n";

        ### HARD DEVELOPMENT
        ### search dot_selektor in cssfile and command this selector complete
        ###
        # suche nach ^.$zeile
        open( my $CSS, "<", $cssfile );
        while (<$CSS>) {
            chomp($_);
            if (/^\.$zeile/) {
                print "found zeile $zeile in css file\n";
            }
        }

    }

}

foreach $zeile (@u_gatter_selektoren) {

    #my $e = skywalker($zeile,$p,$f);
    # grep -i -r -s -h -o --include=*.{pl,cgi,html,php} "id=[\\'\"].*menu." /root/webmin-1.970/virtualx
    my $cmd = 'grep -i -r -s -h -o --include=*.{' . $f . '} "id=[\\\'\"].*' . $zeile . '" ' . $p . '';
    @hit = qx{$cmd};
    my $e = scalar @hit;

    if ( $e == "0" ) {
        print "$zeile\n";
    }

}

### result
###
###
$no001 = scalar @dot_selektoren;
$no002 = scalar @u_dot_selektoren;

$no003 = scalar @gatter_selektoren;
$no004 = scalar @u_gatter_selektoren;

#print "\n";
#print "=============================\n";
#print "$no001 . Selektoren gesamt\n";
#print "$no002 unique . Selektoren\n";
#print "$no003 # Selektoren gesamt\n";
#print "$no004 unique # Selektoren\n";
#print "=============================\n";
#print "\n";

### subtroutines
###
###
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

### suche in html files
###
###
sub skywalker {

    #my ($s) = @_;

    #$string = 'class=\"' . $s . '\"';
    #my $cmd = 'grep -r -s --max-count=1 -h -o --include=*.{' . $f . '} "' . $string . '" ' . $p . '';
    #@hit = qx{$cmd};
    #scalar @hit;

}

### exit
###
###
exit;
