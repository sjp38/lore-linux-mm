Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 39D766B0032
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 20:48:20 -0400 (EDT)
Date: Mon, 19 Aug 2013 10:48:02 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-Id: <20130819104802.e5a8088d87ba81c5ad0d2a66@canb.auug.org.au>
In-Reply-To: <8738q9b8xg.fsf@kernel.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
	<1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
	<20130807145828.GQ2296@suse.de>
	<20130807153743.GH715@cmpxchg.org>
	<20130808041623.GL1845@cmpxchg.org>
	<87haepblo2.fsf@kernel.org>
	<20130816201814.GA26409@cmpxchg.org>
	<8738q9b8xg.fsf@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__19_Aug_2013_10_48_02_+1000_+Bohmn=Bt=ujKf6f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@linaro.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Olof Johansson <olof@lixom.net>, Stephen Warren <swarren@wwwdotorg.org>

--Signature=_Mon__19_Aug_2013_10_48_02_+1000_+Bohmn=Bt=ujKf6f
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Fri, 16 Aug 2013 14:52:11 -0700 Kevin Hilman <khilman@linaro.org> wrote:
>
> Johannes Weiner <hannes@cmpxchg.org> writes:
>=20
> > On Fri, Aug 16, 2013 at 10:17:01AM -0700, Kevin Hilman wrote:
> >> Johannes Weiner <hannes@cmpxchg.org> writes:
> >> > On Wed, Aug 07, 2013 at 11:37:43AM -0400, Johannes Weiner wrote:
> >> > Subject: [patch] mm: page_alloc: use vmstats for fair zone allocatio=
n batching
> >> >
> >> > Avoid dirtying the same cache line with every single page allocation
> >> > by making the fair per-zone allocation batch a vmstat item, which wi=
ll
> >> > turn it into batched percpu counters on SMP.
> >> >
> >> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >>=20
> >> I bisected several boot failures on various ARM platform in
> >> next-20130816 down to this patch (commit 67131f9837 in linux-next.)
> >>=20
> >> Simply reverting it got things booting again on top of -next.  Example
> >> boot crash below.
> >
> > Thanks for the bisect and report!
>=20
> You're welcome.  Thanks for the quick fix!
>=20
> > I deref the percpu pointers before initializing them properly.  It
> > didn't trigger on x86 because the percpu offset added to the pointer
> > is big enough so that it does not fall into PFN 0, but it probably
> > ended up corrupting something...
> >
> > Could you try this patch on top of linux-next instead of the revert?
>=20
> Yup, that change fixes it.
>=20
> Tested-by: Kevin Hilman <khilman@linaro.org>

> Tested-by: Stephen Warren <swarren@nvidia.com>

I will add that into the akpm-current tree in linux-next today (unless
Andrew releases a new mmotm in the mean time).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__19_Aug_2013_10_48_02_+1000_+Bohmn=Bt=ujKf6f
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSEWtGAAoJEECxmPOUX5FEhbsP/1k6qvkvyfiYRoQYuK+QUdHc
GWwufxhiffuxrzkvD3vBfduG/fUzyyW6yOPAc5McJN31TCfvDsh8aLf4vd/j6kDX
O+3GFNTDjIZHTPcUvqhEId9kc9x+WhqTShk4W4Cwo9/3P2hg/1Tq1qMEgwZEH5CT
C7BbYdu2FULnGfdmsWmGcTDRPZNY8Ko4zYwvVkK2fYOtwY+ncUZEHTVccw06VqlV
raexUVrYa/zxtggSTG6i3qo1cGWbRHR/AO2zIuxE5AVnqe0XhoW4KmRhEQ2mAkzx
WJNfzx97/zojPrVOwwKaQs5aklK2F4ze8d0ge46qlMaMd1NRrqauiKJVkAU/uUDI
6bDoOJEiMnh8rOvkMhTa5jN131a+Lp0/L0uQ/sq29bsT4y6bBoPzeb3cGAOfcjSU
oUO8odGJDoOGzvf3nEvsFyBgeYRDuY1EjWoYXM7lIYz7VPNTBGk7DbliAvFD1dVR
kE41avq0EmdL5m54D+KNIWxBsm56V8pS5u68mxlC7ZKwyrm8gByqoAv0nV/8ofqB
JzE6+gsNa3i1lI5PGOhwxG5JxAeWU+hxUHbstCNbv+7jHJs5t/2IK5nHhkerQHSj
f79ONPYoCxgj3gGbeHYzVkghsrCkgI82PukQoel4mXfncbtHVRqxejhX389yh3ck
MxJhLp/x1Qne4ddrVGRf
=7HLW
-----END PGP SIGNATURE-----

--Signature=_Mon__19_Aug_2013_10_48_02_+1000_+Bohmn=Bt=ujKf6f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
