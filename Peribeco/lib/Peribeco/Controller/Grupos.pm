package Peribeco::Controller::Grupos;
use Moose;
use namespace::autoclean;
use Covetel::LDAP;
use Covetel::LDAP::Group;
use utf8;


BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

Peribeco::Controller::Grupos - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect($c->uri_for('/grupos/lista'));
}

sub crear : Local  : FormConfig {
    my ( $self, $c ) = @_;
    if ($c->config->{'Modulos'}->{'Grupos'} == 1 ) {
        if ($c->assert_user_roles(qw/Administradores/)) { 
        $c->stash->{modules} = $c->config->{'Modulos'}; 

        # Clases para los campos requeridos. 
        my $form = $c->stash->{form};
        $form->auto_constraint_class( 'constraint_%t' );
        
        if ( $form->submitted_and_valid ) {
                my $grupo       = $c->req->param("nombre");
                my $descripcion = $c->req->param("descripcion");
    
            #Envia el nuevo Usuario a LDAP
            my $ldap = Covetel::LDAP->new;
            my $group = Covetel::LDAP::Group->new({ 
                nombre => $grupo, 
                description => $descripcion, 
                        ldap => $ldap 
                });
    
            $c->log->debug($group->dn());
    
            if ($group->add()){
                $c->stash->{mensaje} = "El grupo $grupo ha sido
                agregado exitosamente";
                $c->stash->{sucess} = 1;
                }else{
                $c->stash->{error} = 1;
                $c->stash->{mensaje} = "<strong> Error Crítico en LDAP:</strong>".$group->ldap->error_str();
            }
            } elsif ($form->has_errors && $form->submitted) {
            my @err_fields = $form->has_errors;
                    my $label = $form->get_field($err_fields[0])->label; 
    
            $c->stash->{error} = 1;
            $c->stash->{mensaje} = "Ha ocurrido un error en el campo <span class='strong'> $label </span> ";
        }
        }
    }else{
        $c->res->body('Modulo no disponible <a class="enlace" href="/personas/lista" alt="Regresar a lista de Personas"> Regresar </a>');
    }
}

sub lista : Local {
    my ( $self, $c ) = @_;
    if ($c->config->{'Modulos'}->{'Grupos'} == 1 ) {
        if ($c->assert_user_roles(qw/Administradores/)) { 
            my $ldap = Covetel::LDAP->new;
            my @lista = $ldap->group();
            $c->stash->{grupos} = \@lista;
            $c->stash->{modules} = $c->config->{'Modulos'}; 
        }
    }else{
        $c->res->body('Modulo no disponible <a class="enlace" href="/personas/lista" alt="Regresar a lista de Personas"> Regresar </a>');
    }
}

sub eliminar : Local {
    my ( $self, $c, $gid) = @_;
    if ($c->config->{'Modulos'}->{'Grupos'} == 1 ) {
        if ($c->assert_user_roles(qw/Administradores/)) { 
            my $ldap = Covetel::LDAP->new;
            my $grupo = $ldap->group({gidNumber => $gid});
            if ($grupo){
                if($grupo->del()){
                    $c->stash->{mensaje} = "El grupo ".$grupo->nombre." ha sido eliminado exitosamente";
                }
            } else {
                $c->stash->{error} = 1;
                $c->stash->{mensaje} = "No se encontro el grupo";
            }
        }
    }else{
        $c->res->body('Modulo no disponible <a class="enlace" href="/personas/lista" alt="Regresar a lista de Personas"> Regresar </a>');
    }
}

sub detalle : Local {
    my ( $self, $c, $gid) = @_;
    if ($c->config->{'Modulos'}->{'Grupos'} == 1 ) {
        if ($c->assert_user_roles(qw/Administradores/)) { 
            my $ldap = Covetel::LDAP->new;
            my $grupo = $ldap->group({gidNumber => $gid});
    
            if($grupo) {
                my $nombre = $grupo->nombre();
                my $desc = $grupo->description();

                utf8::decode($nombre);
                utf8::decode($desc); 

                $grupo->nombre($nombre);
                $grupo->description($desc);

                $c->stash->{grupo} = $grupo;
            }else{
                $c->res->body('No se encuentra el Grupo')
            }
        }
    }else{
        $c->res->body('Modulo no disponible <a class="enlace" href="/personas/lista" alt="Regresar a lista de Personas"> Regresar </a>');
    }
    $c->stash->{modules} = $c->config->{'Modulos'}; 
}


=head1 AUTHOR

ApHu,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
