package Algorithm::Graphs::TransitiveClosure;

################################################################################
#
# $Author: abigail $
#
# $Date: 1999/03/01 19:51:11 $
#
# $Id: TransitiveClosure.pm,v 1.3 1999/03/01 19:51:11 abigail Exp abigail $
#
# $Log: TransitiveClosure.pm,v $
# Revision 1.3  1999/03/01 19:51:11  abigail
# Renamed primary namespace to Algorithm::
#
# Revision 1.2  1998/03/23 04:00:37  abigail
# Fixed order of loop variables in the ARRAYREF case.
# It's k, i, j, not i, j, k.
#
# Revision 1.1  1998/03/22 06:54:42  abigail
# Initial revision
#
#
#
################################################################################

use strict;
use vars qw /$VERSION @ISA @EXPORT @EXPORT_OK/;

use Exporter;

@ISA       = qw /Exporter/;
@EXPORT    = qw //;
@EXPORT_OK = qw /floyd_warshall/;

($VERSION) = '$Revision: 1.3 $' =~ /(\d+\.\d+)/;


sub floyd_warshall ($) {
    my $graph = shift;
    if (ref $graph eq 'HASH') {
        my @vertices = keys %{$graph};

        foreach my $k (@vertices) {
            foreach my $i (@vertices) {
                foreach my $j (@vertices) {
                    # Don't use ||= here, to avoid autovivication.
                    $graph -> {$i} -> {$j} = 1 if $graph -> {$k} -> {$j} &&
                                                  $graph -> {$i} -> {$k};
                }
            }
        }
    }
    elsif (ref $graph eq 'ARRAY') {
        my $count = @{$graph};
        for (my $k = 0; $k < $count; $k ++) {
            for (my $i = 0; $i < $count; $i ++) {
                for (my $j = 0; $j < $count; $j ++) {
                    $graph -> [$i] -> [$j] ||= $graph -> [$k] -> [$j] &&
                                               $graph -> [$i] -> [$k];
                }
            }
        }
    }

    $graph;
}

1;

__END__


=head1 NAME

Algorithms::Graphs::TransitiveClosure - Calculate the transitive closure.

=head1 SYNOPSIS

    use Algorithms::Graphs::TransitiveClosure qw /floyd_warshall/;

    my $graph = [[1, 0, 0, 0], [0, 1, 1, 1], [0, 1, 1, 0], [1, 0, 1, 1]];
    floyd_warshall $graph;
    print "There is a path from 2 to 0.\n" if $graph -> [2] -> [0];

    my $graph2 = {one   => {one => 1},
                  two   => {two => 1, three => 1, four => 1},
                  three => {two => 1, three => 1},
                  four  => {one => 1, four  => 1}};
    floyd_warshall $graph2;
    print "There is a path from three to one.\n" if
        $graph2 -> {three} -> {one};

=head1 DESCRIPTION

This is an implementation of the well known I<Floyd-Warshall> algorithm. [1,2]

The subroutine C<floyd_warshall> takes a directed graph, and calculates
its transitive closure, which will be returned. The given graph is
actually modified, so be sure to pass a copy of the graph to the routine
if you need to keep the original graph.

The subroutine takes graphs in one of the two following formats:

=over

=item floyd_warshall ARRAYREF

The graph I<G = (V, E)> is described with a list of lists, C<$graph>,
representing I<V x V>. If there is an edge between vertices C<$i> and
C<$j> (or if C<$i == $j>), then C<$graph -E<gt> [$i] -E<gt> [$j] == 1>. For all
other pairs C<($k, $l)> from I<V x V>, C<$graph -E<gt> [$k] -E<gt> [$l] == 0>.

The resulting C<$graph> will have C<$graph -E<gt> [$i] -E<gt> [$j] == 1> iff
C<$i == $j> or there is a path in I<G> from C<$i> to C<$j>, and
C<$graph -E<gt> [$i] -E<gt> [$j] == 0> otherwise.

=item floyd_warshall HASHREF

The graph I<G = (V, E)>, with labeled vertices, is described with
a hash of hashes, C<$graph>, representing I<V x V>. If there is an
edge between vertices C<$label1> and C<$label2> (or if C<$label1 eq $label2>),
then C<$graph -E<gt> {$label1} -E<gt> {$label2} == 1>. For all other pairs
C<($label3, $label4)> from I<V x V>, C<$graph -E<gt> {$label3} -E<gt> {$label4}>
does not exist.

The resulting C<$graph> will have
C<$graph -E<gt> {$label1} -E<gt> {$label2} == 1>
iff C<$label1 eq $label2> or there is a path in I<G> from
C<$label1> to C<$label2>, and C<$graph -E<gt> {$label1} -E<gt> {$label2}>
does not exist otherwise.

=back

=head1 EXAMPLES

    my $graph = [[1, 0, 0, 0],
                 [0, 1, 1, 1],
                 [0, 1, 1, 0],
                 [1, 0, 1, 1]];
    floyd_warshall $graph;
    foreach my $row (@$graph) {print "@$row\n"}

    1 0 0 0
    1 1 1 1
    1 1 1 1
    1 1 1 1

    my $graph = {one   => {one => 1},
                 two   => {two => 1, three => 1, four => 1},
                 three => {two => 1, three => 1},
                 four  => {one => 1, three => 1, four => 1}};
    floyd_warshall $graph;
    foreach my $l1 (qw /one two three four/) {
        print "$l1: ";
        foreach my $l2 (qw /one two three four/) {
            next if $l1 eq $l2;
            print "$l2 " if $graph -> {$l1} -> {$l2};
        }
        print "\n";
    }

    one: 
    two: one three four 
    three: one two four 
    four: one two three 

=head1 COMPLEXITY

The running time of the algorithm is cubed in the number of vertices of the
graph. The author of this package is not aware of any faster algorithms,
nor of a proof if this is optimal. Note than in specific cases, when
the graph can be embedded on surfaces of bounded genus, or in the case
of sparse connection matrices, faster algorithms than cubed in the number
of vertices exist. 

The space used by this algorithm is at most quadratic in the number of
vertices, which is optimal as the resulting transitive closure can have
a quadratic number of edges. In case when the graph is represented as a
list of lists, the quadratic bound will always be achieved, as the list
of lists already has that size. The hash of hashes however will use space
linear to the size of the resulting transitive closure.

=head1 LITERATURE

The Floyd-Warshall algorithm is due to Floyd [2], and based on a
theorem of Warshall [3]. The implemation of this package is based on an
implementation of Floyd-Warshall found in Cormen, Leiserson and Rivest [1].

=head1 REFERENCES

=over

=item [1]

Thomas H. Cormen, Charles E. Leiserson and Ronald L. Rivest:
I<Introduction to Algorithms>. Cambridge: MIT Press, B<1990>.
ISBN 0-262-03141-8.

=item [2]

Robert W. Floyd: "Algorithm 97 (SHORTEST PATH)".
I<Communications of the ACM>, 5(6):345, B<1962>.

=item [3]

Stephan Warshall: "A theorem on boolean matrices."
I<Journal of the ACM>, 9(1):11-12, B<1962>.

=back

=head1 HISTORY

    $Date: 1999/03/01 19:51:11 $

    $Log: TransitiveClosure.pm,v $
    Revision 1.3  1999/03/01 19:51:11  abigail
    Renamed primary namespace to Algorithm::

    Revision 1.2  1998/03/23 04:00:37  abigail
    Fixed order of loop variables in the ARRAYREF case.
    It's k, i, j, not i, j, k.

    Revision 1.1  1998/03/22 06:54:42  abigail
    Initial revision



=head1 AUTHOR

This package was written by Abigail.

=head1 COPYRIGHT

Copyright 1998 by Abigail.

=head1 LICENSE

This package is free and open software.

You may use, copy, modify, distribute and sell this package or any
modifications there of in any form you wish, provided you do not do any
of the following:

    - claim that any of the original code was written by someone
      else than the original author(s).
    - restrict someone in using, copying, modifying, distributing or
      selling this program or module or any modifications of it.


THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut

