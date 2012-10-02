Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 891A96B006E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 11:03:27 -0400 (EDT)
Date: Tue, 2 Oct 2012 17:03:07 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121002150307.GA1161@avionic-0098.mockup.avionic-design.de>
References: <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
 <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
 <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20120928110712.GB29125@suse.de>
 <20120928113924.GA25342@avionic-0098.mockup.avionic-design.de>
 <20120928124332.GC29125@suse.de>
 <20121001142428.GA2798@avionic-0098.mockup.avionic-design.de>
 <20121002124814.GA31316@avionic-0098.mockup.avionic-design.de>
 <20121002144135.GO29125@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Content-Disposition: inline
In-Reply-To: <20121002144135.GO29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 02, 2012 at 03:41:35PM +0100, Mel Gorman wrote:
> On Tue, Oct 02, 2012 at 02:48:14PM +0200, Thierry Reding wrote:
> > > So this really isn't all that new, but I just wanted to confirm my
> > > results from last week. We'll see if bisection shows up something
> > > interesting.
> >=20
> > I just finished bisecting this and git reports:
> >=20
> > 	3750280f8bd0ed01753a72542756a8c82ab27933 is the first bad commit
> >=20
> > I'm attaching the complete bisection log and a diff of all the changes
> > applied on top of the bad commit to make it compile and run on my board.
> > Most of the patch is probably not important, though. There are two hunks
> > which have the pageblock changes I already posted an two other hunks
> > with the patch you posted earlier.
> >=20
> > I hope this helps. If you want me to run any other tests, please let me
> > know.
> >=20
>=20
> Can you test with this on top please?

That doesn't build on top of the bad commit. Or is it supposed to go on
top of next-20120926?

Note that I've also been doing some more testing on next-20121002 and
things seem to be better. The cmatest module runs successfully. That
seems to be due to commit 061d7cd, which, IIRC, is the correct patch to
fix the build breakage that I tried to fix with #ifdef'ery. For CMA this
allows the allocations to succeed, but with COMPACTION enabled this
should still fail. My test case was always !COMPACTION, though.

However, when I run the original test case, which is allocation of a
framebuffer for HDMI it still fails. The allocation size is 8294400
bytes. Exactly 8 MiB (=3D=3D 8388608 bytes) and 16 MiB (=3D=3D 16777216 byt=
es)
do work properly. 8 MiB + 4 KiB for instance fails as well, while
exactly 10 MiB works again.

Thierry

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQawIrAAoJEN0jrNd/PrOhE/cQAJx0DmABCM1jh3DMY156qDxV
34mBbNkEveyRqw9U9VhFkHNyjkMaQLEB15LJl6eh4Pef6gBXl3YWqBUFMHhKiIa6
AkvrnU1QX6233swFs+o2zfc4GXENohW2TBsRXhypvliJviHKGjty/luIeN+Tfboy
J/twmEo+edqAFsjjkMovxu9KNM8+zLBf2dTgNVjCVi9gi81OM7DH2EcHB+P5FAT7
1XRyY9qIhC2Z/FSYHFJu7ppAv8joLAqB30A7BSVwxlJLkMJ6WoW+4VbdfhTeEz33
22ZxQzmvHBrL0ShfGlIJlENmw9V3OLAHAHk+EYpTR0e3GDKFp+9blJoeSG0DtnXG
tt+AbfUJ9ZJjrnWVmwepYaPYeUr3X51KPez1iuOl25ZgBdsE24bjVn581mOaPjgJ
5njPnqpbe6I6XkAToYBoA7JLg7J5yx+6LPw3TaY8dRpUtrUCvnppY5eAp3HJ0cUc
4F69yafwJalXW8ksS5afKDxrpLlM8LsQTi6lJMSk2WYgJJFdB9XuwqWY+EceEOO1
o20wu3p/jU1tA+mPaHU1vxOPyYwGMAOjoVl6sxJ38e97CJxVYaJCHtyDTf4d2UzF
OP3TliGUS16vfowyrbD3lKNzOzoBcmE7sBbdAjXJIEDAItbhxarXGJxV11d/A+UQ
/CkpLvWe+W7bJr6oqAXZ
=V7LJ
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
