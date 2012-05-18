Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 145676B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 21:46:29 -0400 (EDT)
Date: Thu, 17 May 2012 21:46:27 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V11
Message-ID: <20120518014627.GA2177@mgebm.net>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <1337266231-8031-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 17 May 2012, Mel Gorman wrote:

> Mostly addressing feedback from David Miller.
>=20
> Changeloc since V10
>   o Rebase to 3.4-rc5
>   o Coding style fixups						      (davem)
>   o API consistency						      (davem)
>   o Rename sk_allocation to sk_gfp_atomic and use only when necessary (da=
vem)
>   o Use static branches for sk_memalloc_socks			      (davem)
>   o Use static branch checks in fast paths			      (davem)
>   o Document concerns about PF_MEMALLOC leaking flags		      (davem)
>   o Locking fix in slab						      (mel)

The hang happens without these sets.  Unfortunately because my beagle board=
 is
busy and will be through the weekend, I won't be able to test these sets un=
til
the hang is fixed.

Eric

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPtanzAAoJEKhG9nGc1bpJrjoP/02xs7wuoKrc+q6dUXhEhe8g
MvHGqb2fp0o1FxNB8GllGo82DLA8mLX2AzqJ4pziPT2SoCjGqRIkA5E1GC4+o4Yt
JCvH+QdVZqSCk87FxHFLM7TIM9cFQsdT+JWNXyDjgo7YVq1nHTEoxjCocF0RFXqe
zzK7epwlDWm1VtbAIQ0Q4AXezEoVRus1ISZ6jpRtjwSJVv1yE9A3MQQEMWVEKXzo
y32RVGk3xUfaGYYNjK2mnGzGWzwtBEdYTHf5QxEZMKPcAXR+nueNEw8k5oEGdYHI
FIwlAS89DcLfLliQfcphMJ+1ZEmk6s3dMVAXBAr/c1YL0sRftJNWV7Wghgotu4uW
nGpd5LAl4MzCmbupwx/AY9Ie8+Dh8A7zHZL62MpkgM7Y+e5CQGMt9vfAtEvEUfBf
GPTx7B6Hbn/Dp2XCEb45gSisPT5XvYgsWQ3PA8F8ogscqfjxgALtTw7PQZh4cDtO
HV9CxK7ow6aR/R86rgoiNeu/+5g7na7gAoouz/OPzBwSYlhxcQWmUmTYVBRS8p6Y
9Tl+KXOAqeBj+Uei15hx8EXSRtqkuW/usmJTTHsDkWp5rrIehH2B1dAMwPyOza5E
nlkT/WWgcGHP2YY0v2N1SzTltI3rrdM6j/PvafFUQM8rUWQ8Jy7bg0lu/G+1mrwj
f53sXMFKT+DOupRX4FAE
=+nKx
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
