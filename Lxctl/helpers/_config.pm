package Lxctl::helpers::_config;

use strict;
use warnings;

use YAML::Tiny qw(DumpFile LoadFile);

use Lxc::object;

sub load_main
{
	my $self = shift;
	# @config_paths should be hardcoded.
	my @config_paths = ("/etc/lxctl", "/etc", ".");
	foreach my $path (@config_paths) {
		if ( -f "$path/lxctl.yaml" ) {
			my $yaml = YAML::Tiny->new;
			$yaml = YAML::Tiny->read("$path/lxctl.yaml");
			$self->{'lxc'}->set_lxc_conf_dir($yaml->[0]->{'paths'}->{'LXC_CONF_DIR'});
			$self->{'lxc'}->set_roots_path($yaml->[0]->{'paths'}->{'ROOTS_PATH'});
			$self->{'lxc'}->set_config_path($yaml->[0]->{'paths'}->{'CONFIG_PATH'});
			$self->{'lxc'}->set_template_path($yaml->[0]->{'paths'}->{'TEMPLATE_PATH'});
			$self->{'lxc'}->set_vg($yaml->[0]->{'lvm'}->{'VG'});
			my $skip_check = $yaml->[0]->{'check'}->{'skip_kernel_config_check'};
			if (defined($skip_check)) {
				$self->{'lxc'}->set_conf_check($skip_check);
			}
			last;
		}
	}

	return;
}

# hash_ref, filename
#  ex: $config->save_hash("abrakadabra.yaml", \%options);
sub save_hash
{
	my $self = shift;
	my $hash = shift;
	my $filename = shift;

	my %rhash = %$hash;
	DumpFile($filename, \%rhash);

	return;
}

# only arg: filename
#  ex:
#     my $tmp = $config->load_file("abrakadabra.yaml");
#     my %opts = %$tmp;
sub load_file
{
	my $self = shift;
	my $filename = shift;

	my $hash = LoadFile($filename);

	return $hash
}

# Loads hash from file, then modifys it whti hash from 1-st arg
# After that writes back to file.
sub change_hash
{
	my $self = shift;
	my $hash = shift;
	my $filename = shift;

	if ( ! -f $filename ) {
		return;
	}

	my $tmp = $self->load_file($filename);
	my %tmp_hash = %$tmp;
	my %rhash = %$hash;

	foreach my $key (sort keys %rhash) {
		$tmp_hash{$key} = $rhash{$key};
	}

	$self->save_hash(\%tmp_hash, $filename);

	return;
}

sub new
{
	my $class = shift;
	my $self = {};
	bless $self, $class;

	$self->{'lxc'} = new Lxc::object;

	return $self;
}

1;
__END__

=head1 NAME

Lxctl::_config - internal helper module for functions.

=head1 SYNOPSIS

Can read, write and change config files

=head1 DESCRIPTION

Can read, write and change config files

Man page by Capitan Obvious.

=head2 EXPORT

None by default.

=head2 Exportable constants

None by default.

=head2 Exportable functions

TODO

=head1 AUTHOR

Anatoly Burtsev, E<lt>anatolyburtsev@yandex.ruE<gt>
Pavel Potapenkov, E<lt>ppotapenkov@gmail.comE<gt>
Vladimir Smirnov, E<lt>civil.over@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Anatoly Burtsev, Pavel Potapenkov, Vladimir Smirnov

This library is free software; you can redistribute it and/or modify
it under the same terms of GPL v2 or later, or, at your opinion
under terms of artistic license.

=cut