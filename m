Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 66F9B6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 07:03:10 -0400 (EDT)
Date: Tue, 9 Oct 2012 13:02:57 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121009110257.GA6772@avionic-0098.mockup.avionic-design.de>
References: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20121008080654.GD13817@bbox>
 <20121008084806.GH29125@suse.de>
 <201210091040.10811.b.zolnierkie@samsung.com>
 <20121009101143.GQ29125@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <20121009101143.GQ29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Minchan Kim <minchan@kernel.org>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 09, 2012 at 11:11:43AM +0100, Mel Gorman wrote:
> On Tue, Oct 09, 2012 at 10:40:10AM +0200, Bartlomiej Zolnierkiewicz wrote:
> > I also need following patch to make CONFIG_CMA=3Dy && CONFIG_COMPACTION=
=3Dy case
> > work:
> >=20
> > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Subject: [PATCH] mm: compaction: cache if a pageblock was scanned and n=
o pages were isolated - cma fix
> >=20
> > Patch "mm: compaction: cache if a pageblock was scanned and no pages
> > were isolated" needs a following fix to successfully boot next-20121002
> > kernel (same with next-20121008) with CONFIG_CMA=3Dy and CONFIG_COMPACT=
ION=3Dy
> > (with applied -fix1, -fix2, -fix3 patches from Mel Gorman and also with
> > cmatest module from Thierry Reding compiled in).
> >=20
>=20
> Why is it needed to make it boot? CMA should not care about the
> PG_migrate_skip hint being set because it should always ignore it in
> alloc_contig_range() due to cc->ignore_skip_hint. It's not obvious to
> me why this fixes a boot failure and I wonder if it's papering over some
> underlying problem. Can you provide more details please?

I can confirm that on top of next-20121009 this fixes all the remaining
issues with CMA that I've been seeing.

By the way, would it be useful to add the CMA test module to the
mainline tree as a tool to test for this kind of regressions? It could
probably be enhanced to perform more checks or use random allocation
sizes for better coverage.

Thierry

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQdARhAAoJEN0jrNd/PrOhZ8YQAJerUUUmzbkm8wQpJ/y91ts/
MEf9sq7okYa5/WMdX/EKa9im3dwd/12U9xZQWhrUSHicFzQgUgffvyY6kyl8Fzxv
6NX7b/RubzOuQfzAg+uslRFI4SEm7dmXm5tMCFT5xrk/4DBm0lDSrzXbfk5PU7UY
f83yz6G1o+d0lAXQ9MdsXQw5xRQakBzB/4eSH6HzBIir0VMg8bWi0/61DigkUxNT
IvK+vanWrlit8fyxHt2+KF67IXpI9hqhRJcPIZYhrbSWlaS3mTCKqcVLygtOkMdL
dRp9NNxm75fW8T9xDyUoShrQwjSEiGA8h9CSRT7tBV2bj98Iq0iRUY1Rbk9k8hMx
cWRGo6LIkcsbRUdvetLKxcCRy6xdpt6zDXB/TWU7xXSrs/x7wYgoJp1pXGepYuDG
SFphVWIwFeCJRy02S5sbrEt4Ho+nBg42CrHOa8olbbwRLEaz7pLXPIeWDcMBYkFZ
lF2yCKFJZWIlwge4phIEru6gJ9msLBwiPXzArqjzR2YRxYJuOGkPChiQmo/0nVPV
6xQ4DMk+HGyi73skpWG2VVZc0dIa/4AwAvbEHeN6TvuLFlHHOSvhqxnFURaXZeiv
mV7yxAJRfD0ej4YR3JYYMh+ElgGKtkLEHqJklVs6KUzH4Vf5fhKMhUd2JQPfPMpo
jrhR3qNQADX8YW4JXBXJ
=YW2Q
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
