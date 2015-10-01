#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use QVD::DB::Simple;

# Check if DB has to be populated
my $force;
my $datafile = "qvd-init-data.dat";
GetOptions("force|f" => \$force, "file=s" => \$datafile) or exit (1);
unless ($force) {
    eval { db->storage->dbh->do("select count(*) from configs;"); };
    $@ or die "Database already contains QVD tables, use '--force' to redeploy the database\n";
}

### DATA DEFINITION ###

# Check if data file exists
die "$datafile does not exist. Use -file option to select the correct file.\n" unless(-e $datafile);

# Enumarate types
my %enumerates = (
	administrator_and_tenant_views_setups_device_type_enum => [qw(mobile desktop)],
	administrator_and_tenant_views_setups_qvd_object_enum => [qw(user vm log host osf di role administrator tenant)],
	administrator_and_tenant_views_setups_view_type_enum => [qw(filter list_column)],
	log_qvd_object_enum =>
		[qw(user vm log host osf di role administrator tenant acl config tenant_view admin_view)],
	log_type_of_action_enum => [qw(create create_or_update delete see update exec login)],
	wat_setups_by_administrator_and_tenant_language_enum => [qw(es en auto default)],
);

# Initial single values
my %initial_values = (
	VM_State   => [qw(stopped starting running stopping zombie debugging )],
	VM_Cmd     => [qw(start stop busy)],
	User_State => [qw(disconnected connecting connected)],
	User_Cmd   => [qw(abort)],
	Host_State => [qw(stopped starting running stopping lost)],
	Host_Cmd   => [qw(stop)]
);

### DATABASE DEPLOYMENT ###

# Generate database
db->deploy({add_drop_table => 1, add_enums => \%enumerates, add_init_vars => \%initial_values});

# Populate database if DATA is valid
initData({filepath => $datafile}) if initData({filepath => $datafile, check => 1});

### FUNCTIONS ###

sub initData {

	# Check flags
	my %args = %{$_[0]};
	my $filepath = $args{filepath};
	my $checkData = (defined $args{check} and $args{check} > 0) ? 1 : 0;
	my $verbose = (defined $args{verbose} and $args{verbose} > 0) ? 1 : 0;

	print "- Checking initialisation data...\n" if $checkData;
	print "- Populating database...\n" if not $checkData;

	# Variables
	my $outcome = 1;
	open FILE, "<", $filepath or die "Cannot open file $filepath\n";
	my @lines = <FILE>;
	chomp(@lines);
	my $currTableName = '';
	my @currAttribNames = ();
	my @currAttribValues = ();
	my %currAttribHash = ();

	# Check each line of data
	for my $line (@lines) {
		# Remove empty lines
		if (not $line =~ /^\s*$/) {

			# Table reference
			if ($line =~ /^#+\s*(\w+)\s*#+$/) {
				$currTableName = $1;
				@currAttribNames = ();
				%currAttribHash = ();
			} else {
				# Attributes list
				if (@currAttribNames == 0) {
					@currAttribNames = split('\t+', $line);
					print "\n### $currTableName ###\n". join(', ', @currAttribNames) . "\n" if $verbose;
				} else {
					@currAttribValues = split('\t+', $line);
					# Check number of attributes of each row
					if (@currAttribValues != @currAttribNames) {
						print "[ERROR] Number of attributes is different to number of values in line:\n$line\n";
						$outcome = 0;
						last;
					} else { # Add values to the db
						print(join(" | ", @currAttribValues) . "\n") if $verbose;
						@currAttribHash{@currAttribNames} = @currAttribValues;
						rs($currTableName)->create(\%currAttribHash) unless $checkData;
					}
				}
			}
		}

	}

	print "[DONE] Status $outcome\n";
	return $outcome;
}

1;

__DATA__

### Config ###

key	value	tenant_id

wat.multitenant	1	0


### Tenant ###

id	name	description

-1	-	invalid tenant
0	*	supertenant
1	default	tenant1


### Administrator ###

id	name	password	tenant_id	description

0	batman	6pRdrEBsPZiYgYIj/sHChTdtb6EoW/m+yyTTu7GzKVw	0	\N
1	superadmin	kxs9c0f0qnWnPdxubiX2KlCpe/fLcvOkeDqnar/NdKc	0	\N
2	admin	5gdTjBVViDLKyfCyWme65LnIKLIOZ/JYmKL1RvxS+v8	1	\N


### Role ###

id	tenant_id	name	description	fixed	internal

1	-1	Administrators Creator	\N	t	t
2	-1	Administrators Eraser	\N	t	t
3	-1	Administrators Manager	\N	t	t
4	-1	Administrators Operator	\N	t	t
5	-1	Administrators Reader	\N	t	t
6	-1	Administrators Updater	\N	t	t
7	-1	Images Creator	\N	t	t
8	-1	Images Eraser	\N	t	t
9	-1	Images Manager	\N	t	t
10	-1	Images Operator	\N	t	t
11	-1	Images Reader	\N	t	t
12	-1	Images Updater	\N	t	t
13	-1	Logs Manager	\N	t	t
14	-1	Master	\N	t	t
15	-1	Nodes Creator	\N	t	t
16	-1	Nodes Eraser	\N	t	t
17	-1	Nodes Manager	\N	t	t
18	-1	Nodes Operator	\N	t	t
19	-1	Nodes Reader	\N	t	t
20	-1	Nodes Updater	\N	t	t
21	-1	OSFs Creator	\N	t	t
22	-1	OSFs Eraser	\N	t	t
23	-1	OSFs Manager	\N	t	t
24	-1	OSFs Operator	\N	t	t
25	-1	OSFs Reader	\N	t	t
26	-1	OSFs Updater	\N	t	t
27	-1	QVD Config Manager	\N	t	t
28	-1	QVD Creator	\N	t	t
29	-1	QVD Eraser	\N	t	t
30	-1	QVD Manager	\N	t	t
31	-1	QVD Operator	\N	t	t
32	-1	QVD Reader	\N	t	t
33	-1	QVD Updater	\N	t	t
34	-1	Roles Creator	\N	t	t
35	-1	Roles Eraser	\N	t	t
36	-1	Roles Manager	\N	t	t
37	-1	Roles Operator	\N	t	t
38	-1	Roles Reader	\N	t	t
39	-1	Roles Updater	\N	t	t
40	1	Tenants Creator	\N	t	t
41	-1	Tenants Eraser	\N	t	t
42	-1	Tenants Manager	\N	t	t
43	-1	Tenants Reader	\N	t	t
44	-1	Tenants Updater	\N	t	t
45	-1	Total Master	\N	t	t
46	-1	Users Creator	\N	t	t
47	-1	Users Eraser	\N	t	t
48	-1	Users Manager	\N	t	t
49	-1	Users Operator	\N	t	t
50	-1	Users Reader	\N	t	t
51	-1	Users Updater	\N	t	t
52	-1	Views Manager	\N	t	t
53	-1	Views Operator	\N	t	t
54	-1	Views Reader	\N	t	t
55	-1	VMs Creator	\N	t	t
56	-1	VMs Eraser	\N	t	t
57	-1	VMs Manager	\N	t	t
58	-1	VMs Operator	\N	t	t
59	-1	VMs Reader	\N	t	t
60	-1	VMs Updater	\N	t	t
61	-1	WAT Config Manager	\N	t	t
62	-1	WAT Manager	\N	t	t
63	-1	Operator L1	\N	t	f
64	-1	Operator L2	\N	t	f
65	-1	Operator L3	\N	t	f
66	-1	Root	\N	t	f


### ACL ###
id	name	description

1	administrator.create.	Create administrators
2	administrator.create.language	Set language on administrator creation
3	administrator.delete.	Delete administrators
4	administrator.delete-massive.	Delete administrators (massive)
5	administrator.filter.created-by	Filter administrators by creator
6	administrator.filter.creation-date	Filter administrators by creation date
7	administrator.filter.name	Filter administrators by name
8	administrator.see.acl-list	See administrator's ACLs
9	administrator.see.acl-list-roles	See source roles of Administrator's ACL
10	administrator.see.created-by	See administrator's creator
11	administrator.see.creation-date	See administrator's creation date
12	administrator.see.description	See administrator's description
13	administrator.see-details.	Access to administrator's details view
14	administrator.see.id	See administrator's ID
15	administrator.see.language	See administrator's language
16	administrator.see.log	See administrator's Log
17	administrator.see-main.	Access to administrator's main section
18	administrator.see.roles	See administrator's Roles
19	administrator.update.assign-role	Assign-Unassign administrator's roles
20	administrator.update.description	Update administrator's description
21	administrator.update.language	Update administrator's language
22	administrator.update-massive.description	Update administrator's description (massive)
23	administrator.update-massive.language	Update administrator's language (massive)
24	administrator.update.password	Change administrator's password
25	config.qvd.	QVD's configuration management
26	config.wat.	WAT's configuration management
27	di.create.	Create disk images
28	di.create.default	Set disk images as default on disk images creation
29	di.create.properties	Set properties on disk images creation
30	di.create.tags	Set tags on disk images creation
31	di.create.version	Set version on disk images creation
32	di.delete.	Delete disk images
33	di.delete-massive.	Delete disk images (massive)
34	di.filter.block	Filter disk images by blocking state
35	di.filter.created-by	Filter disk images by creator
36	di.filter.creation-date	Filter disk images by creation date
37	di.filter.disk-image	Filter disk images by DI's name
38	di.filter.osf	Filter disk images by OS Flavour
39	di.filter.properties	Filter disk images by properties
40	di.see.block	See disk image's blocking state
41	di.see.created-by	See disk image's creator
42	di.see.creation-date	See disk image's creation date
43	di.see.default	See OSF's default disk image
44	di.see.description	See disk image's description
45	di.see-details.	Access to disk image's details view
46	di.see.head	See OSF's last created disk image
47	di.see.id	See disk image's ID
48	di.see.log	See disk image's Log
49	di.see-main.	Access to disk image's main section
50	di.see.osf	See disk image's OS Flavour
51	di.see.properties	See disk image's properties
52	di.see.tags	See disk image's tags
53	di.see.version	See disk image's version
54	di.see.vm-list	See disk image's list of virtual machines
55	di.see.vm-list-block	See blocking state of VM's list of DI's
56	di.see.vm-list-expiration	See expiration of VM's list of DI's
57	di.see.vm-list-state	See running state of VM's list of DI's
58	di.see.vm-list-user-state	See user state of VM's list of DI's
59	di.stats.blocked	See statistics of number of blocked disk images
60	di.stats.summary	See statistics of number of disk images
61	di.update.block	Block-Unblock disk images
62	di.update.default	Set disk images as default
63	di.update.description	Update disk image's description
64	di.update-massive.block	Block-Unblock disk images (massive)
65	di.update-massive.description	Update disk image's description (massive)
66	di.update-massive.properties	Update properties when update disk images (massive)
67	di.update-massive.tags	Update disk image's tags (massive)
68	di.update.properties	Update properties when update disk images
69	di.update.tags	Update disk image's tags
70	host.create.	Create nodes
71	host.create.properties	Set properties on nodes in creation
72	host.delete.	Delete nodes
73	host.delete-massive.	Delete nodes (massive)
74	host.filter.block	Filter nodes by blocking state
75	host.filter.created-by	Filter nodes by creator
76	host.filter.creation-date	Filter nodes by creation date
77	host.filter.name	Filter nodes by name
78	host.filter.properties	Filter nodes by properties
79	host.filter.state	Filter nodes by running state
80	host.filter.vm	Filter nodes by virtual machines
81	host.see.address	See node's IP address
82	host.see.block	See node's blocking state
83	host.see.created-by	See node's creator
84	host.see.creation-date	See node's creation date
85	host.see.description	See node's description
86	host.see-details.	Access to node's details view
87	host.see.id	See node's ID
88	host.see.log	See node's Log
89	host.see-main.	Access to node's main section
90	host.see.properties	See node's properties
91	host.see.state	See node's running state
92	host.see.vm-list	See node's running virtual machines
93	host.see.vm-list-block	See node's running virtual machines' blocking state
94	host.see.vm-list-expiration	See node's running virtual machines' expiration
95	host.see.vm-list-state	See node's running virtual machines' running state
96	host.see.vm-list-user-state	See node's running virtual machine' user state
97	host.see.vms-info	See number of running vms running on nodes
98	host.stats.blocked	See statistics of number of blocked nodes
99	host.stats.running-hosts	See statistics of running nodes
100	host.stats.summary	See statistics of number of nodes
101	host.stats.top-hosts-most-vms	See statistics of nodes with most running Vms
102	host.update.address	Update node's address
103	host.update.block	Block-Unblock nodes
104	host.update.description	Update node's description
105	host.update-massive.block	Block-Unblock nodes (massive)
106	host.update-massive.description	Update node's description (massive)
107	host.update-massive.properties	Update properties when update nodes (massive)
108	host.update-massive.stop-vms	Stop all virtual machines of a node (massive)
109	host.update.name	Update node's name
110	host.update.properties	Update properties when update nodes
111	host.update.stop-vms	Stop all virtual machines of a node
112	log.filter.action	Filter log by action
113	log.filter.administrator	Filter log by administrator
114	log.filter.date	Filter log by date
115	log.filter.object	Filter log by object
116	log.filter.response	Filter log by response
117	log.filter.source	Filter log by source
118	log.see.address	See log's IP address
119	log.see.administrator	See log's administrator
120	log.see.call-arguments	See log's call arguments
121	log.see-details.	Access to log's details view
122	log.see-main.	Access to log's main section
123	log.see.source	See log's source
124	osf.create.	Create OS Flavours
125	osf.create.memory	Set memory in OS Flavour's creation
126	osf.create.properties	Set properties in OS Flavour's creation
127	osf.create.user-storage	Set user storage in OS Flavour's creation
128	osf.delete.	Delete OS Flavours
129	osf.delete-massive.	Delete OS Flavours (massive)
130	osf.filter.created-by	Filter OS Flavours by creator
131	osf.filter.creation-date	Filter OS Flavours by creation date
132	osf.filter.di	Filter OS Flavours by disk image
133	osf.filter.name	Filter OS Flavours by name
134	osf.filter.properties	Filter OS Flavours by properties
135	osf.filter.vm	Filter OS Flavours by virtual machine
136	osf.see.created-by	See OS Flavour's creator
137	osf.see.creation-date	See OS Flavour's creation date
138	osf.see.description	See OS Flavour's description
139	osf.see-details.	Access to OS Flavour's details view
140	osf.see.di-list	See OS Flavour's disk images
141	osf.see.di-list-block	See OS Flavour's disk images' blocking state
142	osf.see.di-list-default	See OS Flavour's disk images' default state
143	osf.see.di-list-default-update	Change OS Flavour's disk images' default info
144	osf.see.di-list-head	See OS Flavour's disk images' head info
145	osf.see.di-list-tags	See OS Flavour's disk images' tags
146	osf.see.dis-info	See number of OS Flavour's disk images
147	osf.see.id	See OS Flavour's ID
148	osf.see.log	See OS Flavour's Log
149	osf.see-main.	Access to OS Flavour's main section
150	osf.see.memory	See OS Flavour's memory
151	osf.see.overlay	See OS Flavour's overlay
152	osf.see.properties	See OS Flavour's properties
153	osf.see.user-storage	See OS Flavour's user storage
154	osf.see.vm-list	See OS Flavour's virtual machines
155	osf.see.vm-list-block	See OS Flavour's virtual machines' blocking state
156	osf.see.vm-list-expiration	See OS Flavour's virtual machines' expiration
157	osf.see.vm-list-state	See OS Flavour's virtual machines' running state
158	osf.see.vm-list-user-state	See OS Flavour's virtual machines' user state
159	osf.see.vms-info	See number of OS Flavour's virtual machines
160	osf.stats.summary	See statistics of number of OS Flavours
161	osf.update.description	Update OS Flavour's description
162	osf.update-massive.description	Update OS Flavour's description (massive)
163	osf.update-massive.memory	Update OS Flavour's memory (massive)
164	osf.update-massive.properties	Update properties when update OSFs (massive)
165	osf.update-massive.user-storage	Update OS Flavour's user storage (massive)
166	osf.update.memory	Update OS Flavour's memory
167	osf.update.name	Update OS Flavour's name
168	osf.update.properties	Update properties when update OSFs
169	osf.update.user-storage	Update OS Flavour's user storage
170	property.manage.di	Manage disk image's custom properties
171	property.manage.host	Manage node's custom properties
172	property.manage.osf	Manage OSF's custom properties
173	property.manage.user	Manage user's custom properties
174	property.manage.vm	Manage virtual machines's custom properties
175	property.see-main.	Access to properties's main section
176	role.create.	Create roles
177	role.delete.	Delete roles
178	role.delete-massive.	Delete roles (massive)
179	role.filter.created-by	Filter roles by creator
180	role.filter.creation-date	Filter roles by creation date
181	role.filter.name	Filter role by name
182	role.see.acl-list	See role's acls
183	role.see.acl-list-roles	See role's acls' origin roles
184	role.see.created-by	See role's creator
185	role.see.creation-date	See role's creation date
186	role.see.description	See role's description
187	role.see-details.	Access to role's details view
188	role.see.id	See role's ID
189	role.see.inherited-roles	See role's inherited roles
190	role.see.log	See role's Log
191	role.see-main.	Access to role's main section
192	role.update.assign-acl	Assign-Unassign role's ACLs
193	role.update.assign-role	Assign-Unassign role's inherited roles
194	role.update.description	Update role's description
195	role.update-massive.description	Update role's description (massive)
196	role.update.name	Update role's name
197	tenant.create.	Create tenants
198	tenant.delete.	Delete tenants
199	tenant.delete-massive.	Delete tenants (massive)
200	tenant.filter.created-by	Filter tenants by creator
201	tenant.filter.creation-date	Filter tenants by creation date
202	tenant.filter.name	Filter tenant by name
203	tenant.see.blocksize	See tenant's block size
204	tenant.see.created-by	See tenant's creator
205	tenant.see.creation-date	See tenant's creation date
206	tenant.see.description	See tenant's description
207	tenant.see-details.	Access to tenant's details view
208	tenant.see.di-list	See tenant's disk images
209	tenant.see.di-list-block	See tenant's disk blocking state
210	tenant.see.di-list-tags	See tenant's disk images' tags
211	tenant.see.id	See tenant's ID
212	tenant.see.language	See tenant's language
213	tenant.see.log	See tenant's Log
214	tenant.see-main.	Access to tenant's main section
215	tenant.see.user-list	See tenant's users
216	tenant.see.user-list-block	See tenant's user blocking state
217	tenant.see.vm-list	See tenant's virtual machines
218	tenant.see.vm-list-block	See tenant's virtual machines blocking state
219	tenant.see.vm-list-expiration	See tenant's virtual machines' expiration date
220	tenant.see.vm-list-state	See tenant's virtual machines' running state
221	tenant.see.vm-list-user-state	See tenant's virtual machines' user state
222	tenant.update.blocksize	Update tenant's block size
223	tenant.update.description	Update tenant's description
224	tenant.update.language	Update tenant's language
225	tenant.update-massive.blocksize	Update tenant's block size (massive)
226	tenant.update-massive.description	Update tenant's description (massive)
227	tenant.update-massive.language	Update tenant's language (massive)
228	tenant.update.name	Update tenant's name
229	user.create.	Create users
230	user.create.properties	Set properties on users in creation
231	user.delete.	Delete users
232	user.delete-massive.	Delete users (massive)
233	user.filter.block	Filter users by blocking state
234	user.filter.created-by	Filter users by creator
235	user.filter.creation-date	Filter users by creation date
236	user.filter.name	Filter users by name
237	user.filter.properties	Filter users by properties
238	user.see.block	See user's blocking state
239	user.see.created-by	See user's creator
240	user.see.creation-date	See user's creation date
241	user.see.description	See user's description
242	user.see-details.	Access to user's details view
243	user.see.id	See user's ID
244	user.see.log	See user's Log
245	user.see-main.	Access to user's main section
246	user.see.properties	See user's properties
247	user.see.vm-list	See user's virtual machines
248	user.see.vm-list-block	See user's virtual machines' blocking state
249	user.see.vm-list-expiration	See user's virtual machines' expiration
250	user.see.vm-list-state	See user's virtual machines' running state
251	user.see.vm-list-user-state	See user's virtual machines' user state
252	user.see.vms-info	See number of user's virtual machines
253	user.stats.blocked	See statistics of number of users
254	user.stats.connected-users	See statistics of number of connected users
255	user.stats.summary	See statistics of number of blocked users
256	user.update.block	Block-Unblock users
257	user.update.description	Update user's description
258	user.update-massive.block	Block-Unblock users (massive)
259	user.update-massive.description	Update user's description (massive)
260	user.update-massive.properties	Update properties when update users (massive)
261	user.update.password	Update user's password
262	user.update.properties	Update properties when update users
263	views.see-main.	Access to default view's main section
264	views.update.columns	Set default columns on list views
265	views.update.filters-desktop	Set default filters on list views for desktop
266	views.update.filters-mobile	Set default filters on list views for mobile
267	vm.create.	Create virtual machines
268	vm.create.di-tag	Set tag in virtual macine's creation
269	vm.create.properties	Set properties in virtual machine's creation
270	vm.delete.	Delete virtual machines
271	vm.delete-massive.	Delete virtual machines (massive)
272	vm.filter.block	Filter virtual machines by blocking state
273	vm.filter.created-by	Filter virtual machines by creator
274	vm.filter.creation-date	Filter virtual machines by creation date
275	vm.filter.expiration-date	Filter virtual machines by expiration date
276	vm.filter.host	Filter virtual machines by node
277	vm.filter.name	Filter virtual machines by name
278	vm.filter.osf	Filter virtual machines by OS Flavour
279	vm.filter.properties	Filter virtual machines by properties
280	vm.filter.state	Filter virtual machines by running state
281	vm.filter.user	Filter virtual machines by user
282	vm.see.block	See virtual machine's blocking status
283	vm.see.created-by	See virtual machine's creator
284	vm.see.creation-date	See virtual machine's creation date
285	vm.see.description	See virtual machine's description
286	vm.see-details.	Access to virtual machine's details view
287	vm.see.di	See virtual machine's disk image
288	vm.see.di-tag	See virtual machine's disk image's tag
289	vm.see.di-version	See virtual machine's disk image's version
290	vm.see.expiration	See virtual machine's Expiration
291	vm.see.host	See virtual machine's Node
292	vm.see.id	See virtual machine's ID
293	vm.see.ip	See virtual machine's IP address
294	vm.see.log	See virtual machine's Log
295	vm.see.mac	See virtual machine's MAC address
296	vm.see-main.	Access to virtual machine's main section
297	vm.see.next-boot-ip	See virtual machine's IP address for next boot
298	vm.see.osf	See virtual machine's OS Flavour
299	vm.see.port-serial	See virtual machine's Serial port
300	vm.see.port-ssh	See virtual machine's SSH port
301	vm.see.port-vnc	See virtual machine's VNC port
302	vm.see.properties	See virtual machine's properties
303	vm.see.state	See virtual machine's state
304	vm.see.user	See virtual machine's user
305	vm.see.user-state	See virtual machine's user's connection state
306	vm.stats.blocked	See statistics of number of blocked virtual machines
307	vm.stats.close-to-expire	See statistics of virtual machines close to expire
308	vm.stats.running-vms	See statistics of running virtual machines
309	vm.stats.summary	See statistics of number of virtual machines
310	vm.update.block	Block-Unblock virtual machines
311	vm.update.description	Update virtual machine's description
312	vm.update.disconnect-user	Disconnect user from virtual machine
313	vm.update.di-tag	Update virtual machine's tag
314	vm.update.expiration	Update virtual machine's expiration
315	vm.update-massive.block	Block-Unblock virtual machines (massive)
316	vm.update-massive.description	Update virtual machine's description (massive)
317	vm.update-massive.disconnect-user	Disconnect user from virtual machine (massive)
318	vm.update-massive.di-tag	Update virtual machine's tag (massive)
319	vm.update-massive.expiration	Update virtual machine's expiration (massive)
320	vm.update-massive.properties	Update properties when update virtual machines (massive)
321	vm.update-massive.state	Start-Stop virtual machines (massive)
322	vm.update.name	Update virtual machine's name
323	vm.update.properties	Update properties when update virtual machines
324	vm.update.state	Start-Stop virtual machines


### ACL_Role_Relation ###
id	acl_id	role_id	positive

1	1	1	t
2	2	1	t
3	3	2	t
4	4	2	t
5	5	5	t
6	6	5	t
7	7	5	t
8	8	5	t
9	9	5	t
10	10	5	t
11	11	5	t
12	12	5	t
13	13	5	t
14	14	5	t
15	15	5	t
16	16	5	t
17	17	5	t
18	18	5	t
19	19	4	t
20	20	6	t
21	21	6	t
22	22	6	t
23	23	6	t
24	24	6	t
25	25	27	t
26	26	61	t
27	27	7	t
28	28	7	t
29	29	7	t
30	30	7	t
31	31	7	t
32	32	8	t
33	33	8	t
34	34	11	t
35	35	11	t
36	36	11	t
37	37	11	t
38	38	11	t
39	39	11	t
40	40	11	t
41	41	11	t
42	42	11	t
43	43	11	t
44	44	11	t
45	45	11	t
46	46	11	t
47	47	11	t
48	48	11	t
49	49	11	t
50	50	11	t
51	51	11	t
52	52	11	t
53	53	11	t
54	54	11	t
55	55	11	t
56	56	11	t
57	57	11	t
58	58	11	t
59	59	11	t
60	60	11	t
61	61	10	t
62	62	10	t
63	63	12	t
64	64	10	t
65	65	12	t
66	66	12	t
67	67	12	t
68	68	12	t
69	69	12	t
70	70	15	t
71	71	15	t
72	72	16	t
73	73	16	t
74	74	19	t
75	75	19	t
76	76	19	t
77	77	19	t
78	78	19	t
79	79	19	t
80	80	19	t
81	81	19	t
82	82	19	t
83	83	19	t
84	84	19	t
85	85	19	t
86	86	19	t
87	87	19	t
88	88	19	t
89	89	19	t
90	90	19	t
91	91	19	t
92	92	19	t
93	93	19	t
94	94	19	t
95	95	19	t
96	96	19	t
97	97	19	t
98	98	19	t
99	99	19	t
100	100	19	t
101	101	19	t
102	102	20	t
103	103	18	t
104	104	20	t
105	105	18	t
106	106	20	t
107	107	20	t
108	108	18	t
109	109	20	t
110	110	20	t
111	111	18	t
112	112	13	t
113	113	13	t
114	114	13	t
115	115	13	t
116	116	13	t
117	117	13	t
118	118	13	t
119	119	13	t
120	120	13	t
121	121	13	t
122	122	13	t
123	123	13	t
124	124	21	t
125	125	21	t
126	126	21	t
127	127	21	t
128	128	22	t
129	129	22	t
130	130	25	t
131	131	25	t
132	132	25	t
133	133	25	t
134	134	25	t
135	135	25	t
136	136	25	t
137	137	25	t
138	138	25	t
139	139	25	t
140	140	25	t
141	141	25	t
142	142	25	t
143	143	24	t
144	144	25	t
145	145	25	t
146	146	25	t
147	147	25	t
148	148	25	t
149	149	25	t
150	150	25	t
151	151	25	t
152	152	25	t
153	153	25	t
154	154	25	t
155	155	25	t
156	156	25	t
157	157	24	t
158	157	63	t
159	157	25	t
160	158	25	t
161	159	25	t
162	160	25	t
163	161	26	t
164	162	26	t
165	163	26	t
166	164	26	t
167	165	26	t
168	166	26	t
169	167	26	t
170	168	26	t
171	169	26	t
172	170	27	t
173	171	27	t
174	172	27	t
175	173	27	t
176	174	27	t
177	175	27	t
178	176	34	t
179	177	35	t
180	178	35	t
181	179	38	t
182	180	38	t
183	181	38	t
184	182	38	t
185	183	38	t
186	184	38	t
187	185	38	t
188	186	38	t
189	187	38	t
190	188	38	t
191	189	38	t
192	190	38	t
193	191	38	t
194	192	37	t
195	193	37	t
196	194	39	t
197	195	39	t
198	196	39	t
199	197	40	t
200	198	41	t
201	199	41	t
202	200	43	t
203	201	43	t
204	202	43	t
205	203	43	t
206	204	43	t
207	205	43	t
208	206	43	t
209	207	43	t
210	208	43	t
211	209	43	t
212	210	43	t
213	211	43	t
214	212	43	t
215	213	43	t
216	214	43	t
217	215	43	t
218	216	43	t
219	217	43	t
220	218	43	t
221	219	43	t
222	220	43	t
223	221	43	t
224	222	44	t
225	223	44	t
226	224	44	t
227	224	66	t
228	225	44	t
229	226	44	t
230	227	44	t
231	228	66	t
232	228	44	t
233	229	46	t
234	230	46	t
235	231	47	t
236	232	47	t
237	233	50	t
238	234	50	t
239	235	50	t
240	236	50	t
241	237	50	t
242	238	50	t
243	239	50	t
244	240	50	t
245	241	50	t
246	242	50	t
247	243	50	t
248	244	50	t
249	245	50	t
250	246	50	t
251	247	50	t
252	247	66	t
253	248	50	t
254	249	50	t
255	250	50	t
256	251	50	t
257	252	50	t
258	253	50	t
259	254	50	t
260	255	50	t
261	256	49	t
262	257	51	t
263	258	49	t
264	259	51	t
265	260	51	t
266	261	51	t
267	262	51	t
268	263	54	t
269	264	53	t
270	265	53	t
271	266	53	t
272	267	55	t
273	268	55	t
274	269	55	t
275	270	56	t
276	271	56	t
277	272	59	t
278	273	59	t
279	274	59	t
280	275	59	t
281	276	59	t
282	277	59	t
283	278	59	t
284	279	59	t
285	280	59	t
286	281	59	t
287	282	59	t
288	283	59	t
289	284	59	t
290	285	59	t
291	286	59	t
292	287	59	t
293	288	59	t
294	289	59	t
295	290	59	t
296	291	59	t
297	292	59	t
298	293	59	t
299	294	59	t
300	295	59	t
301	296	59	t
302	297	59	t
303	298	59	t
304	299	59	t
305	300	59	t
306	301	59	t
307	302	59	t
308	303	59	t
309	304	59	t
310	305	59	t
311	306	59	t
312	307	59	t
313	308	59	t
314	309	59	t
315	310	58	t
316	311	60	t
317	312	58	t
318	313	60	t
319	314	60	t
320	315	58	t
321	316	60	t
322	317	58	t
323	318	60	t
324	319	60	t
325	320	60	t
326	321	58	t
327	322	63	f
328	322	60	t
329	323	60	t
330	324	58	t


### Role_Administrator_Relation ###
id	role_id	administrator_id

1	1	1
2	1	2


### Wat_Setups_By_Administrator ###
id	block	language	administrator_id

0	10	auto	0
1	10	auto	1
2	10	auto	2


### Wat_Setups_By_Tenant ###
id	block	language	tenant_id

0	10	auto	0
1	10	auto	1


### Role_Role_Relation ###
id	inheritor_id	inherited_id

1	66	45
2	52	53
3	52	54
4	42	44
5	42	41
6	42	43
7	42	40
8	36	38
9	36	34
10	36	39
11	36	35
12	36	37
13	3	6
14	3	2
15	3	4
16	3	5
17	3	1
18	9	7
19	9	8
20	9	10
21	9	11
22	9	12
23	23	24
24	23	26
25	23	22
26	23	21
27	23	25
28	17	18
29	17	19
30	17	16
31	17	20
32	17	15
33	57	60
34	57	58
35	57	59
36	57	55
37	57	56
38	48	49
39	48	46
40	48	51
41	48	47
42	48	50
43	28	7
44	28	46
45	28	55
46	28	21
47	32	25
48	32	50
49	32	59
50	32	11
51	33	26
52	33	51
53	33	60
54	33	12
55	29	8
56	29	22
57	29	56
58	29	47
59	31	10
60	31	58
61	31	49
62	31	24
63	30	57
64	30	48
65	30	27
66	30	9
67	30	23
68	62	13
69	62	52
70	62	36
71	62	61
72	62	3
73	14	30
74	14	62
75	45	17
76	45	14
77	45	42
78	63	32
79	64	31
80	64	63
81	65	17
82	65	64
83	65	29
84	65	28
85	65	33
