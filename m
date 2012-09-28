Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 38B6A6B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 06:38:31 -0400 (EDT)
Date: Fri, 28 Sep 2012 12:38:15 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
 <20120928083722.GM3429@suse.de>
 <50656459.70309@ti.com>
 <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AhhlLboLdkugWU4S"
Content-Disposition: inline
In-Reply-To: <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 28, 2012 at 12:32:07PM +0200, Thierry Reding wrote:
> On Fri, Sep 28, 2012 at 11:27:28AM +0100, Mel Gorman wrote:
> > On Fri, Sep 28, 2012 at 11:48:25AM +0300, Peter Ujfalusi wrote:
> > > Hi,
> > >=20
> > > On 09/28/2012 11:37 AM, Mel Gorman wrote:
> > > >> I hope this patch fixes the bug. If this patch fixes the problem
> > > >> but has some problem about description or someone has better idea,
> > > >> feel free to modify and resend to akpm, Please.
> > > >>
> > > >=20
> > > > A full revert is overkill. Can the following patch be tested as a
> > > > potential replacement please?
> > > >=20
> > > > ---8<---
> > > > mm: compaction: Iron out isolate_freepages_block() and isolate_free=
pages_range() -fix1
> > > >=20
> > > > CMA is reported to be broken in next-20120926. Minchan Kim pointed =
out
> > > > that this was due to nr_scanned !=3D total_isolated in the case of =
CMA
> > > > because PageBuddy pages are one scan but many isolations in CMA. Th=
is
> > > > patch should address the problem.
> > > >=20
> > > > This patch is a fix for
> > > > mm-compaction-acquire-the-zone-lock-as-late-as-possible-fix-2.patch
> > > >=20
> > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > >=20
> > > linux-next + this patch alone also works for me.
> > >=20
> > > Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>
> >=20
> > Thanks Peter. I expect it also works for Thierry as I expect you were
> > suffering the same problem but obviously confirmation of that would be =
nice.
>=20
> I've been running a few tests and indeed this solves the obvious problem
> that the coherent pool cannot be created at boot (which in turn caused
> the ethernet adapter to fail on Tegra).
>=20
> However I've been working on the Tegra DRM driver, which uses CMA to
> allocate large chunks of framebuffer memory and these are now failing.
> I'll need to check if Minchan's patch solves that problem as well.

Indeed, with Minchan's patch the DRM can allocate the framebuffer
without a problem. Something else must be wrong then.

Thierry

--AhhlLboLdkugWU4S
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQZX4XAAoJEN0jrNd/PrOhi9AQAIaZuZREkYgC9l4CZdt/vwhX
zDaW9mGsgx7WNlX3sJcQ+xu4N5jhf/WJKuH6wE09ei50PeMAQAPm7uLsDugLJUvq
OglKZmeKAn9BbWXmWWlUmGAcfjhemnX9IuvjG3EZiFX10x9SALnU79deo2Yl0rWJ
4mnK/97NOOEWQJHWU9xnH/PB/Oh50ysNqOnYaOUUgvrUcWjE1Z9Sy9bnaSbfllwP
ZX4Cr7hLS5k6nQpCur3XbuZlLB+hpmDNj8f2A0dzJkoRyk+xIwwLVo/n1Nhqvi5M
tYUhLia048214+D013cRHWxjM5iJcyLz91FToyc8JetkCprKRKAMaVr/1K4VBzRU
ZeiwatTEs/3tSSqtCjNlcJsPz+vY7BOTD3AOnSLXZybKfXN3Z8ErFq4kCnUb6WLn
jjGm9K7Q7nsLOdJmf0cB+gXW5LpVZpMjxpJjQ+KO7XqK9fmaRyzPwGltddixwr9q
DYLunbNrdJUNXd/WFnrTxPMrE/mtJvY0cqrv64W2kaNJ1/FZ80q1gxEkLg78DgHt
T6ZW2FaMuZLiH/3HqLx+DGPQBOgkcmoBGwf/3xwRi6jHfOadQMuviXJ3TfwRbRNe
5Z1D9TS4FFPDC/3Zy63hh+IJpjuLFMCtEsVsnI90tCYx07rQS8/UnJV2EnZytvpR
UrP6bCYFGvHx7ZfhCZRY
=3emU
-----END PGP SIGNATURE-----

--AhhlLboLdkugWU4S--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
