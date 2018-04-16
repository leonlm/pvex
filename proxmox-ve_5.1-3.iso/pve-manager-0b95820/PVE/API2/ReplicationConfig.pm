package PVE::API2::ReplicationConfig;

use warnings;
use strict;

use PVE::Tools qw(extract_param);
use PVE::Exception qw(raise_perm_exc raise_param_exc);
use PVE::JSONSchema qw(get_standard_option);
use PVE::RPCEnvironment;
use PVE::ReplicationConfig;
use PVE::Cluster;

use PVE::RESTHandler;

use base qw(PVE::RESTHandler);

__PACKAGE__->register_method ({
    name => 'index',
    path => '',
    method => 'GET',
    description => "List replication jobs.",
    permissions => {
	description => "Requires the VM.Audit permission on /vms/<vmid>.",
	user => 'all',
    },
    parameters => {
	additionalProperties => 0,
	properties => {},
    },
    returns => {
	type => 'array',
	items => {
	    type => "object",
	    properties => {},
	},
	links => [ { rel => 'child', href => "{id}" } ],
    },
    code => sub {
	my ($param) = @_;

	my $rpcenv = PVE::RPCEnvironment::get();
	my $authuser = $rpcenv->get_user();

	my $cfg = PVE::ReplicationConfig->new();

	my $res = [];
	foreach my $id (sort keys %{$cfg->{ids}}) {
	    my $d = $cfg->{ids}->{$id};
	    my $vmid = $d->{guest};
	    next if !$rpcenv->check($authuser, "/vms/$vmid", [ 'VM.Audit' ]);
	    $d->{id} = $id;
	    push @$res, $d;
	}

	return $res;
    }});

__PACKAGE__->register_method ({
    name => 'read',
    path => '{id}',
    method => 'GET',
    description => "Read replication job configuration.",
    permissions => {
	description => "Requires the VM.Audit permission on /vms/<vmid>.",
	user => 'all',
    },
    parameters => {
    	additionalProperties => 0,
	properties => {
	    id => get_standard_option('pve-replication-id'),
	},
    },
    returns => { type => 'object' },
    code => sub {
	my ($param) = @_;

	my $rpcenv = PVE::RPCEnvironment::get();
	my $authuser = $rpcenv->get_user();

	my $cfg = PVE::ReplicationConfig->new();

	my $data = $cfg->{ids}->{$param->{id}};

	die "no such replication job '$param->{id}'\n" if !defined($data);

	my $vmid = $data->{guest};

	raise_perm_exc() if !$rpcenv->check($authuser, "/vms/$vmid", [ 'VM.Audit' ]);

	$data->{id} = $param->{id};

	$data->{digest} = $cfg->{digest};

	return $data;
    }});

__PACKAGE__->register_method ({
    name => 'create',
    path => '',
    protected => 1,
    method => 'POST',
    description => "Create a new replication job",
    permissions => {
	check => ['perm', '/storage', ['Datastore.Allocate']],
    },
    parameters => PVE::ReplicationConfig->createSchema(),
    returns => { type => 'null' },
    code => sub {
	my ($param) = @_;

	my $type = extract_param($param, 'type');
	my $plugin = PVE::ReplicationConfig->lookup($type);
	my $id = extract_param($param, 'id');

	# extract guest ID from job ID
	my ($guest) = PVE::ReplicationConfig::parse_replication_job_id($id);

	my $nodelist = PVE::Cluster::get_members();
	my $vmlist = PVE::Cluster::get_vmlist();

	my $guest_info = $vmlist->{ids}->{$guest};
	die "Guest '$guest' does not exists.\n"
	    if !defined($guest_info);
	die "Target '$param->{target}' does not exists.\n"
	    if defined($param->{target}) && !defined($nodelist->{$param->{target}});

	my $guest_class = $PVE::API2::Replication::lookup_guest_class->($guest_info->{type});
	my $guest_conf = $guest_class->load_config($guest, $guest_info->{node});
	my $rep_volumes = $guest_class->get_replicatable_volumes(PVE::Storage::config(), $guest, $guest_conf, 0, 0);
	die "No replicatable volumes found\n" if !%$rep_volumes;

	my $code = sub {
	    my $cfg = PVE::ReplicationConfig->new();

	    die "replication job '$id' already exists\n"
		if $cfg->{ids}->{$id};

	    my $opts = $plugin->check_config($id, $param, 1, 1);

	    $opts->{guest} = $guest;

	    $cfg->{ids}->{$id} = $opts;

	    $cfg->write();
	};

	PVE::ReplicationConfig::lock($code);

	return undef;
    }});


__PACKAGE__->register_method ({
    name => 'update',
    protected => 1,
    path => '{id}',
    method => 'PUT',
    description => "Update replication job configuration.",
    permissions => {
	check => ['perm', '/storage', ['Datastore.Allocate']],
    },
    parameters => PVE::ReplicationConfig->updateSchema(),
    returns => { type => 'null' },
    code => sub {
	my ($param) = @_;

	my $id = extract_param($param, 'id');
	my $digest = extract_param($param, 'digest');
	my $delete = extract_param($param, 'delete');

	my $code = sub {
	    my $cfg = PVE::ReplicationConfig->new();

	    PVE::SectionConfig::assert_if_modified($cfg, $digest);

	    my $data = $cfg->{ids}->{$id};
	    die "no such job '$id'\n" if !$data;

	    my $plugin = PVE::ReplicationConfig->lookup($data->{type});
	    my $opts = $plugin->check_config($id, $param, 0, 1);

	    foreach my $k (%$opts) {
		$data->{$k} = $opts->{$k};
	    }

	    if ($delete) {
		my $options = $plugin->private()->{options}->{$data->{type}};
		foreach my $k (PVE::Tools::split_list($delete)) {
		    my $d = $options->{$k} ||
			die "no such option '$k'\n";
		    die "unable to delete required option '$k'\n"
			if !$d->{optional};
		    die "unable to delete fixed option '$k'\n"
			if $d->{fixed};
		    delete $data->{$k};
		}
	    }

	    $cfg->write();
	};

	PVE::ReplicationConfig::lock($code);

	return undef;
    }});

__PACKAGE__->register_method ({
    name => 'delete',
    protected => 1,
    path => '{id}',
    method => 'DELETE',
    description => "Mark replication job for removal.",
    permissions => {
	check => ['perm', '/storage', ['Datastore.Allocate']],
    },
    parameters => {
    	additionalProperties => 0,
	properties => {
	    id => get_standard_option('pve-replication-id'),
	    keep => {
		description => "Keep replicated data at target (do not remove).",
		type => 'boolean',
		optional => 1,
		default => 0,
	    },
	    force => {
		description => "Will remove the jobconfig entry, but will not cleanup.",
		type => 'boolean',
		optional => 1,
		default => 0,
	    },
	}
    },
    returns => { type => 'null' },
    code => sub {
	my ($param) = @_;

	my $rpcenv = PVE::RPCEnvironment::get();

	my $code = sub {
	    my $cfg = PVE::ReplicationConfig->new();

	    my $id = $param->{id};
	    if ($param->{force}) {
		raise_param_exc({ 'keep' => "conflicts with parameter 'force'" }) if $param->{keep};
		delete $cfg->{ids}->{$id};
	    } else {
		my $jobcfg = $cfg->{ids}->{$id};
		die "no such job '$id'\n" if !$jobcfg;

		if (!$param->{keep} && $jobcfg->{type} eq 'local') {
		    # remove local snapshots and remote volumes
		    $jobcfg->{remove_job} = 'full';
		} else {
		    # only remove local snapshots
		    $jobcfg->{remove_job} = 'local';
		}

		warn "Replication job removal is a background task and will take some time.\n"
		    if $rpcenv->{type} eq 'cli';
	    }
	    $cfg->write();
	};

	PVE::ReplicationConfig::lock($code);

	return undef;
    }});

1;
