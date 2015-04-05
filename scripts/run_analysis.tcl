#!/usr/bin/tclsh

if { $argc != 2 } {
	puts "This script requires 2 parameters:"
	puts "\t1) Input data in CSV format with unix-style line endings"
	puts "\t2) Output filename"
	return
}

# setup IO
set infile [open [lindex $argv 0] r]
set outfile [open [lindex $argv 1] w]

# initialize the datastructure and some counters
array unset data; array set data {}
set docNumCounter 0
set maxTopicNum 0


puts -nonewline "Reading input file..."; flush stdout
# loop through the input
while { ![eof $infile] } {
	# read in a line and split on comma (input type is CSV)
	set inLine [split [string trim [gets $infile]] ,]

	# skip any comments, e.g., document header, or empty lines
	if { [string index [lindex $inLine 0] 0] eq "#" || $inLine eq "" } { continue }

	# parse out the document number
	set docNum [lindex $inLine 0]

	# parse out the topic number and value in pairs
	foreach {topicNum value} [lrange $inLine 2 end] {
		set data($docNum,$topicNum) $value
		if { $topicNum > $maxTopicNum } { set maxTopicNum $topicNum }
	}

	incr docNumCounter
}

puts "done"; flush stdout
puts "$docNumCounter documents found"; flush stdout
puts "maximum topic number found: $maxTopicNum"; flush stdout

# Write the output
# print the header
puts -nonewline "writing data to output file..."; flush stdout
puts -nonewline $outfile ",";
for {set i 0} {$i <= $maxTopicNum} {incr i} {
	puts -nonewline $outfile "$i,"
}
puts $outfile ""; flush $outfile


# print the data lines
for {set i 0} {$i < $docNumCounter} {incr i} {

	# row organized by document number
	puts -nonewline $outfile "$i"

	# column organized by topic number
	for {set j 0} {$j <= $maxTopicNum} {incr j} {
		if { [info exists data($i,$j)] } {
			puts -nonewline $outfile "\t$data($i,$j)"; flush $outfile
		} else {
			puts -nonewline $outfile "\t0.0"; flush $outfile
		}
	}

	# advance output to next line
	puts $outfile ""
}

# close up output
close $outfile
puts "done"; flush stdout
