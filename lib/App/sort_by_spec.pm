package App::sort_by_spec;

use 5.010001;
use strict;
use warnings;
use Log::ger;

use AppBase::Sort;
use AppBase::Sort::File ();
use Perinci::Sub::Util qw(gen_modified_sub);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

gen_modified_sub(
    output_name => 'sort_by_spec',
    base_name   => 'AppBase::Sort::sort_appbase',
    summary     => 'Sort lines of text by spec',
    description => <<'_',

This utility lets you sort lines of text by spec. For more details, see
<pm:Sort::BySpec>.

_
    add_args    => {
        %AppBase::Sort::File::argspecs_files,
        specs => {
            'x.name.is_plural' => 1,
            'x.name.singular' => 'spec',
            schema => ['array*', of=>'str_or_re_or_code*'],
            req => 1,
            pos => 0,
            slurpy => 1,
        },
    },
    modify_args => {
        files => sub {
            my $argspec = shift;
            delete $argspec->{pos};
            delete $argspec->{slurpy};
        },
    },
    modify_meta => sub {
        my $meta = shift;

        $meta->{examples} = [
            {
                src_plang => 'bash',
                src => q[ perl -E 'say for (1..15,42)' | sort-by-spec 'qr([13579]\z)' 'sub { $_[0] <=> $_[1] }' 4 2 42 'qr([13579]\z)' 'sub { $_[0] <=> $_[1] }'],
                summary => 'Put odd numbers first in ascending order, then put the specific numbers (4,2,42), then put even numbers last in descending order',
                description => <<'MARKDOWN',

This example is taken from the <pm:Sort::BySpec>'s Synopsis.

MARKDOWN
                test => 0,
                'x.doc.show_result' => 0,
            },
        ];

        $meta->{links} //= [];
        push @{ $meta->{links} }, {url=>'pm:Sort::BySpec'};
        push @{ $meta->{links} }, {url=>'pm:App::sort_by_example'};
    },
    output_code => sub {
        my %args = @_;
        my $examples = delete $args{examples};

        AppBase::Sort::File::set_source_arg(\%args);
        $args{_sortgen} = sub {
            my $args = shift;
            require Sort::BySpec;
            my $spec = $args->{specs};
            my $cmp = Sort::ByExample::cmp_by_spec(spec => $spec, reverse => $args->{reverse});
            my $sort = sub {
                my ($a, $b) = @_;
                chomp($a); chomp($b);
                if ($args->{ignore_case}) { $a = lc $a; $b = lc $b }
                $cmp->($a, $b);
            };
            return ($sort, 1);
        };
        AppBase::Sort::sort_appbase(%args);
    },
);

1;
# ABSTRACT:
