Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5546B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 05:51:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 1so18862297pgz.5
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 02:51:36 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id g187si929603pgc.52.2017.02.22.02.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 02:51:35 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 5so1857937pgj.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 02:51:35 -0800 (PST)
Date: Wed, 22 Feb 2017 18:51:31 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170222105131.GA57616@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
 <20170207153247.GB31837@WeideMBP.lan>
 <20170207154120.GW5065@dhcp22.suse.cz>
 <20170209135929.GA59297@WeideMacBook-Pro.local>
 <20170222084947.GE5753@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Content-Disposition: inline
In-Reply-To: <20170222084947.GE5753@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 22, 2017 at 09:49:47AM +0100, Michal Hocko wrote:
>On Thu 09-02-17 21:59:29, Wei Yang wrote:
>> On Tue, Feb 07, 2017 at 04:41:21PM +0100, Michal Hocko wrote:
>> >On Tue 07-02-17 23:32:47, Wei Yang wrote:
>> >> On Tue, Feb 07, 2017 at 10:45:57AM +0100, Michal Hocko wrote:
>> >[...]
>> >> >Is there any reason why for_each_mem_pfn_range cannot be changed to
>> >> >honor the given start/end pfns instead? I can imagine that a small z=
one
>> >> >would see a similar pointless iterations...
>> >> >
>> >>=20
>> >> Hmm... No special reason, just not thought about this implementation.=
 And
>> >> actually I just do the similar thing as in zone_spanned_pages_in_node=
(), in
>> >> which also return 0 when there is no overlap.
>> >>=20
>> >> BTW, I don't get your point. You wish to put the check in
>> >> for_each_mem_pfn_range() definition?
>> >
>> >My point was that you are handling one special case (an empty zone) but
>> >the underlying problem is that __absent_pages_in_range might be wasting
>> >cycles iterating over memblocks that are way outside of the given pfn
>> >range. At least this is my understanding. If you fix that you do not
>> >need the special case, right?
>> >--=20
>> >Michal Hocko
>> >SUSE Labs
>>=20
>> > Not really, sorry, this area is full of awkward and subtle code when n=
ew
>> > changes build on top of previous awkwardness/surprises. Any cleanup
>> > would be really appreciated. That is the reason I didn't like the
>> > initial check all that much.
>>=20
>> Looks my fetchmail failed to get your last reply. So I copied it here.
>>=20
>> Yes, the change here looks not that nice, while currently this is what I=
 can't
>> come up with.
>
>THen I will suggest dropping this patch from the mmotm tree because it
>doesn't sound like a big improvement and I would encourage you or
>anybody else to take a deeper look and unclutter this area to be more
>readable and better maintainable.

Hi, Michal

I don't get your point, which part of the code makes you feel uncomfortable?

The behavior here is similar in zone_spanned_pages_in_node(), in which it a=
lso
checks whether this node has pages within the zone's required range. The
improvement may not that much, while the logic here is clear. If the node h=
as
no page in the zone's required range, it is not necessary to continue the
calculation.

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYrW0zAAoJEKcLNpZP5cTdY+8P/0dWoBaVr81uPBivqbGPIUZi
QYAcO8XDb7Q9y30j20ti0KBtY53ikx34ZR0OxOxpU2DBxPq/kQxnUtl3c/JShDiT
/SsHjvwYIArEE6rCfyS/DHCFtMTsdsNKE+4+vJcaDtWTg4j75GeM1hFuKjfn2h4w
SIilh4HInTaGBwOX+0F+17i1IWASU+Whwc7WP/AeStflLE5xynrkwk2F7ubotJxQ
nxtBjshRsaZGRBZl0kDSR5vywK5WHrbuhKVvJyBLBbEvccRdF6onLuP37pEunPE6
A6Uk+L9SuT45QmM/vf6I9ffsmaDLdGTu6QaqWOvaRJ4M0hb//5jvuWNbDyYX04xR
52aCID5irPtdkSkOV1nnRtbI0RGUFjMGLvNJUCk2iODTKbOmuXnlqb1/jbrQStAP
qk7NGXU6Ergna40oDSEeiYiuiRo0E4/jvVjhTz+TNtSEXJEIhNEjEO3j7J1FpRt/
K4wgUUEC0m+LobcU1S8TZChhmGoLZhayClVzWvlA1M2v/iQdgzmLrwahrAHflllq
O7hSrXyz1yHMRGIyTEDDuvG9FjkFSbIVCpBKyUJN646MhDvCXhUAosnImGnO1wgA
ssDAuPb8PxY1zClDZbkLLJ1nlDryGZ3JjHtgxtzotwWvViAn7zcWTk0+NgNezFtd
0T4IcGNFWoWFIiu+uBE9
=JPph
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
