sub print
{
	my($self) = @_;

	print 'address_id: ', $self -> id(), ". \n";
	print map{"\tCampus: " . $_ -> campus_official_name() . "\n"} $self -> campus();
	print "\tEmail:  ", $self -> address_email(), ". \n";
	print "\tFax:    ", $self -> address_fax(), ". \n";
	print "\tLine:   ", $self -> address_line(), ". \n";
	print "\tPhone:  ", $self -> address_phone(), ". \n";
	print "\n";

}	# End of print.
