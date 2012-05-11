Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 9D3178D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:57:12 -0400 (EDT)
Date: Sat, 12 May 2012 01:56:57 +0300
From: Sami Liedes <sami.liedes@iki.fi>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-ID: <20120511225657.GE7387@sli.dy.fi>
References: <bug-43227-27@https.bugzilla.kernel.org/>
 <20120511125921.a888e12c.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1205111419060.1288@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="EgVrEAR5UttbsTXg"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205111419060.1288@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org


--EgVrEAR5UttbsTXg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 11, 2012 at 02:30:42PM -0700, Hugh Dickins wrote:
> The only thought I have on this report: what binutils was used to build
> this kernel?  We had "Bad page" and isolate_lru_pages BUG reports at the
> start of the month, and they were traced to buggy binutils 2.22.52.0.2

Debian unstable's binutils 2.22-6.

	Sami

--EgVrEAR5UttbsTXg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCgAGBQJPrZk5AAoJEKLT589SE0a0jF4P/1pAzZ9yWN3J1xRm8mYi2iU1
FipXjU9mMk4omyVwI/VEuVetco6uELDwja3C/lIcz9OS3AGSSS6QlYU5GHVJstyY
CVFbQgr5uWegrpdDo6+1eU09CbhVHqGfcLvbMIvCddBFRyfg3w4HnE8ZqX7qJ5bF
rxuyF92qhawAR/jQ73iXJPhE3Y9WYdA768oY/aHVzUCK7Po3uF5vzYew8n/MXPV9
WB07OocuI4+RXHfCwO9VBSwS1B01tVL7Iudv9AMfzO9pFglCbt5Ge8zaecaHqHKx
M55HU1tWUCUEvI2MkzWs5+BHNR64BhXu1sCoZHbGR8aBGTKl7cfENqZBQok82cf7
o42tgwvawSsX9pfr09Pa4qEvdD7hy+XEx5EZuQBfMMTG30WXBh9HDVUbjvPxyD9B
r8Fg/HOC1QGlD+zCePK72L6MLp8AdaxZo56/nTKZ/UWrBHIWmv0niulhofKrr3iJ
AJRVriQwHef2kzdYhCXXcFxPTAEoa3YZqtezkKcyq2+lzTEumBQn//PjtzWT8zTn
Ckg2At4i20KqSoR5qZg4L2ceVM+BqAAOTGLyAO4+wWsspbTW1SYIwmgaiQZVgK4O
WB9q1Af9Pa2Pvbk19w7krevCH6x8bVglOou0n3pTGr/V0/GEUAq1s/b97SGeaEKG
C/4CuTMwCoxGO7bXL6MR
=1U3B
-----END PGP SIGNATURE-----

--EgVrEAR5UttbsTXg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
