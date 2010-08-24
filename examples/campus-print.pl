sub print
{
	my($self) = @_;

	print 'campus_id: ', $self -> id(), ". \n";
	print "\tOfficial name: ", $self -> campus_official_name(), ". \n";
	print "\tType: ", $self -> campus_campus_type_id() -> campus_type_name(), ". \n";
	print "\tAddress: ", $self -> campus_address_id() -> address_line(), ". \n";
	print "\n";

}	# End of print.
