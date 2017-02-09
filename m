Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEAFB6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:59:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v184so5389591pgv.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:59:34 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s24si10109046pfj.271.2017.02.09.05.59.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 05:59:34 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id e4so295251pfg.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:59:34 -0800 (PST)
Date: Thu, 9 Feb 2017 21:59:29 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170209135929.GA59297@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
 <20170207153247.GB31837@WeideMBP.lan>
 <20170207154120.GW5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Content-Disposition: inline
In-Reply-To: <20170207154120.GW5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 07, 2017 at 04:41:21PM +0100, Michal Hocko wrote:
>On Tue 07-02-17 23:32:47, Wei Yang wrote:
>> On Tue, Feb 07, 2017 at 10:45:57AM +0100, Michal Hocko wrote:
>[...]
>> >Is there any reason why for_each_mem_pfn_range cannot be changed to
>> >honor the given start/end pfns instead? I can imagine that a small zone
>> >would see a similar pointless iterations...
>> >
>>=20
>> Hmm... No special reason, just not thought about this implementation. And
>> actually I just do the similar thing as in zone_spanned_pages_in_node(),=
 in
>> which also return 0 when there is no overlap.
>>=20
>> BTW, I don't get your point. You wish to put the check in
>> for_each_mem_pfn_range() definition?
>
>My point was that you are handling one special case (an empty zone) but
>the underlying problem is that __absent_pages_in_range might be wasting
>cycles iterating over memblocks that are way outside of the given pfn
>range. At least this is my understanding. If you fix that you do not
>need the special case, right?
>--=20
>Michal Hocko
>SUSE Labs

> Not really, sorry, this area is full of awkward and subtle code when new
> changes build on top of previous awkwardness/surprises. Any cleanup
> would be really appreciated. That is the reason I didn't like the
> initial check all that much.

Looks my fetchmail failed to get your last reply. So I copied it here.

Yes, the change here looks not that nice, while currently this is what I ca=
n't
come up with.

Thanks for your review :-)

--=20
Wei Yang
Help you, Help me

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYnHXBAAoJEKcLNpZP5cTdgikP/1Z5yeEIKmTtPTQyUPQ5ZU3T
fP5kfNWqCDc01hTDy5c8ETQilzCaM/YZqzWnESqGO2sjAqZsxrabc5qoY5WKemBm
nF3ozz/VpOxiVd+UWgOBAnJeXoJ6qCRdenvQBYp45Jh44IYTnXmCqU/EY+s+jERu
G6E2+H4ySdqi1/XZb/TwSS3wlpr9lrnEoHfCzDzfzyNb8mNm7XNDFQXtIsWUdVVx
t1dw1KSqvD2l+r0y1s2eL/o0uKD+mAozPxCokvrMHLN2cHGOpVVtP4YkIw6lMESJ
g3hONsRe2yzpfBntdsv1LTjHmarJq8ZIy45WSw1960ur/p4EiYoKbtnK2yZCxv6R
M7EaBmQzXLP4aLkMVif4nI31hGXGCib5slisXluVMYTjJanVrvA88KqzC8zmUNnF
Z2iZ5MVupWU2McKC4xXgyhv6wh9qfH1SngybkU+JqKFy9g+wTySWbwUN9dCf4Kub
M15h9I43FNkrVKRO5qTLDX6T3x5U2gCkk2zPyBEhxqZcJ3gzZz9/M4WAJLdIXUtD
EgZotTG31Q6XCnYGQEkWz4hcaWTBZM5ZRv/3mWOEP+ghnuC0VgfczmK3PCIQmyiW
kDdfFmEL7/qpCNAelFIQp4/47o2d1IlV50etCrsNCOM3uDKNx0o1/+GMVotRaDQF
RtoMmcyB01v6vbVUFYAx
=HREn
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
