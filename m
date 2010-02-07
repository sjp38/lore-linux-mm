Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C53A6B0047
	for <linux-mm@kvack.org>; Sun,  7 Feb 2010 13:36:18 -0500 (EST)
From: Tony Lill <ajlill@ajlc.waterloo.on.ca>
Subject: Re: [Bugme-new] [Bug 15214] New: Oops at __rmqueue+0x51/0x2b3
Date: Sun, 7 Feb 2010 13:34:58 -0500
References: <bug-15214-10286@http.bugzilla.kernel.org/> <20100203143921.f2c96e8c.akpm@linux-foundation.org> <20100205112000.GD20412@csn.ul.ie>
In-Reply-To: <20100205112000.GD20412@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3074631.N22m1qMyuY";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201002071335.03984.ajlill@ajlc.waterloo.on.ca>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

--nextPart3074631.N22m1qMyuY
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable

On Friday 05 February 2010 06:20:00 Mel Gorman wrote:
> On Wed, Feb 03, 2010 at 02:39:21PM -0800, Andrew Morton wrote:
> > > gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
>=20
> This is a bit of a reach, but how confident are you that this version of
> gcc is building kernels correctly?
>
> There are a few disconnected reports of kernel problems with this
> particular version of gcc although none that I can connect with this
> problem or on x86 for that matter. One example is
>=20
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D536354
>=20
> which reported problems building kernels on the s390 with that compiler.
> Moving to 4.2 helped them and it *should* have been fixed according to
> this bug
>=20
> http://bugzilla.kernel.org/show_bug.cgi?id=3D13012
>=20
> It might be a red herring, but just to be sure, would you mind trying
> gcc 4.2 or 4.3 just to be sure please?

Well, it was producing working kernels up until 2.6.30, but I recompiled wi=
th
gcc (Debian 4.3.2-1.1) 4.3.2
and the box has been running nearly 48 hour without incident. My previous=20
record was 2. So I guess we can put this down to a new compiler bug.

I probably should have checked this before reporting a bug. Mea culpa
=2D-=20
Tony Lill,                         Tony.Lill@AJLC.Waterloo.ON.CA
President, A. J. Lill Consultants                 (519) 650 0660
539 Grand Valley Dr., Cambridge, Ont. N3H 2S2     (519) 241 2461
=2D-------------- http://www.ajlc.waterloo.on.ca/ ----------------



--nextPart3074631.N22m1qMyuY
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAktvB9MACgkQGS8yZq1uvxA1FACfZfy0uVHt4Rl3n3Gy0yyGiK9x
eykAni8FM0qMTcWlwHcru0UJ1hF1ofnU
=PZ+7
-----END PGP SIGNATURE-----

--nextPart3074631.N22m1qMyuY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
