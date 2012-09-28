Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id AB1826B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 02:11:11 -0400 (EDT)
Date: Fri, 28 Sep 2012 08:10:56 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928061056.GA13458@avionic-0098.mockup.avionic-design.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RnlQjJ0d97Da+TV1"
Content-Disposition: inline
In-Reply-To: <20120928054330.GA27594@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Mel Gorman <mgorman@suse.de>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 28, 2012 at 02:43:30PM +0900, Minchan Kim wrote:
> On Thu, Sep 27, 2012 at 03:11:59PM -0700, Andrew Morton wrote:
> > On Thu, 27 Sep 2012 13:29:11 +0200
> > Thierry Reding <thierry.reding@avionic-design.de> wrote:
> >=20
> > > Hi Marek,
> > >=20
> > > any idea why CMA might be broken in next-20120926. I see that there
> > > haven't been any major changes to CMA itself, but there's been quite a
> > > bit of restructuring of various memory allocation bits lately. I wasn=
't
> > > able to track the problem down, though.
> > >=20
> > > What I see is this during boot (with CMA_DEBUG enabled):
> > >=20
> > > [    0.266904] cma: dma_alloc_from_contiguous(cma db474f80, count 64,=
 align 6)
> > > [    0.284469] cma: dma_alloc_from_contiguous(): memory range at c09d=
7000 is busy, retrying
> > > [    0.293648] cma: dma_alloc_from_contiguous(): memory range at c09d=
7800 is busy, retrying
> > > ...
> > > [    2.648619] DMA: failed to allocate 256 KiB pool for atomic cohere=
nt allocation
> > > ...
> > > [    4.196193] WARNING: at /home/thierry.reding/src/kernel/linux-ipmp=
=2Egit/arch/arm/mm/dma-mapping.c:485 __alloc_from_pool+0xdc/0x110()
> > > [    4.207988] coherent pool not initialised!
> > >=20
> > > So the pool isn't getting initialized properly because CMA can't get =
at
> > > the memory. Do you have any hints as to what might be going on? If it=
's
> > > any help, I started seeing this with next-20120926 and it is in today=
's
> > > next as well.
> > >=20
> >=20
> > Bart and Minchan have made recent changes to CMA.  Let us cc them.
>=20
> Hi all,
>=20
> I have no time now so I look over the problem during short time
> so I mighte be wrong. Even I should leave the office soon and
> Korea will have long vacation from now on so I will be off by next week.
> So it's hard to reach on me.
>=20
> I hope this patch fixes the bug. If this patch fixes the problem
> but has some problem about description or someone has better idea,
> feel free to modify and resend to akpm, Please.
>=20
> Thierry, Could you test below patch?
>=20
> >From 24a547855fa2bd4212a779cc73997837148310b3 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 28 Sep 2012 14:28:32 +0900
> Subject: [PATCH] revert mm: compaction: iron out isolate_freepages_block()
>  and isolate_freepages_range()
>=20
> [1] made bug on CMA.
> The nr_scanned should be never equal to total_isolated for successful CMA.
> This patch reverts part of the patch.
>=20
> [1] mm: compaction: iron out isolate_freepages_block() and isolate_freepa=
ges_range()
>=20
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/compaction.c |   29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)

With that patch applied I see this now:

[    0.255177] DMA: preallocated 256 KiB pool for atomic coherent allocatio=
ns

so this fixes the bug for me.

Tested-by: Thierry Reding <thierry.reding@avionic-design.de>

--RnlQjJ0d97Da+TV1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQZT9wAAoJEN0jrNd/PrOhZs0P/R88ms+xrV16gEOjEshUz2Jn
A1apn4OJxuQ7PzaFObQn4p0FgXmfCNP/Yd8c7hVotL4ciVjXuUtaeK8OnzNpWz5m
2MGbSCIzitvYijnNn0ph1cS5vbTDU2sBJY8RlqYjG8H1+lM/ISRV+5cWXh0R7wsd
mb1k/snsehVZ9xDxkrAz7o+KD8Gm6y7Yn0R060UfQH+5XmjdUM5/KIP3shg4IVKR
Gg9b9mAc2wNWmE6Anu+jRM6ktQ1HXz4IkMgstf1NSZ25XtwqPDoBeH+vl0l80mrr
3LMe0YyRbscgD3hmprWZ5nzRCkbPGxZApbNO3h2kZS625vW0exYwzR+yIXEb9GpK
vR3pBineuAHE1Qzydl8oH83qWYXlEupvqF5Gs10aTdq1YIemWJ6n9ldEACyVqCsZ
lfSPO23D8e72ozzQOnM0m48+om+ntNBKQMaedSbRgpMjkQ7Yd2g0mB1SgJy9fMlZ
ynqIxCoWvojr76BxlWdZE1I6tqBWdgJSmSuscI35XrGCe/Tw3RgdOT1b+OphbvuJ
u+JZu7F9EIdvLmQT3At+brvLao3lsVlvdETQBJExQiyKwmIjSB1q5L/wmBKSLwo8
xK2dBXV0rq6EA6UWVrHklxFpcZQDmPnLZUA1H/lQWzekiDw300ghXo5pNjcw1GzR
pEePJwXuUppkT90NWHme
=bgcT
-----END PGP SIGNATURE-----

--RnlQjJ0d97Da+TV1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
