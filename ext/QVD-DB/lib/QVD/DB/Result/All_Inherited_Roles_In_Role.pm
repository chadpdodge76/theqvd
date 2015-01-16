package QVD::DB::Result::All_Inherited_Roles_In_Role;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('all_inherited_acls_in_roles');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"

SELECT DISTINCT * FROM all_role_role_relations

"
);

__PACKAGE__->add_columns(

    inheritor_id  => { data_type => 'integer' },
    inherited_id  => { data_type => 'integer' },
);

__PACKAGE__->set_primary_key( qw/ inheritor_id inherited_id / );


1;
