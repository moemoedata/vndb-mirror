package VNTask::EL::JASTUSA;

use v5.36;
use VNTask::ExtLinks;
use FU::Util 'json_parse';

sub fetch($task, $lnk) {
    my $res = http_get 'https://jaststore.com/games/'.$lnk->value,
        task   => 'Affiliate Crawler',
        cookie => 'regional-zone=USA; currency=USD';
    $res->dead('Not found') if $res->code eq 404;
    $res->expect(200);

    my $ldjson = $res->body =~ m{<script type="application/ld\+json">(.*?)</script>}s
        ? $1
        : $res->err('No embedded json metadata found');
    my $json = json_parse $ldjson, utf8 => 1;

    my $url = ref $json eq 'HASH' && $json->{url}
        ? $json->{url}
        : $res->err('No product URL found');

    $url =~ m{/games/\Q$lnk->{value}\E/(.+)$}
        or $res->err('Unexpected product URL');
    my $slug = $1;

    my $offer = ref $json->{offers} eq 'HASH'
        ? $json->{offers}
        : $res->err('No offer information found');

    $res->err('Unexpected currency')
        if $offer->{priceCurrency} ne 'USD';

    my $price =
        $offer->{price} && $offer->{price} ne '0.00'
        ? sprintf 'US$ %.02f', $offer->{price}
        : 'free';

    $lnk->save(price => $price, data => $slug);
    $task->done('Available at /%s for %s', $slug, $price);
}

el_queue 'el/jastusa',
    freq   => '4d',
    triage => sub($lnk) { $lnk->site eq 'jastusa' },
    \&fetch;

1;
