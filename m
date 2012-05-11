Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id E89B88D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:23:46 -0400 (EDT)
Date: Sat, 12 May 2012 01:23:41 +0300
From: Sami Liedes <sami.liedes@iki.fi>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-ID: <20120511222341.GD7387@sli.dy.fi>
References: <bug-43227-27@https.bugzilla.kernel.org/>
 <20120511125921.a888e12c.akpm@linux-foundation.org>
 <20120511200213.GB7387@sli.dy.fi>
 <20120511133234.6130b69a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="VV4b6MQE+OnNyhkM"
Content-Disposition: inline
In-Reply-To: <20120511133234.6130b69a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org


--VV4b6MQE+OnNyhkM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 11, 2012 at 01:32:34PM -0700, Andrew Morton wrote:
> Sure, thanks, that might turn something up.=20
> Documentation/SubmitChecklist recommends=20
>=20
> : 12: Has been tested with CONFIG_PREEMPT, CONFIG_DEBUG_PREEMPT,
> :     CONFIG_DEBUG_SLAB, CONFIG_DEBUG_PAGEALLOC, CONFIG_DEBUG_MUTEXES,
> :     CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_ATOMIC_SLEEP, CONFIG_PROVE_RCU
> :     and CONFIG_DEBUG_OBJECTS_RCU_HEAD all simultaneously enabled.
>=20
> although that list might be a bit out of date; it certainly should
> include CONFIG_DEBUG_VM!

I wonder if there's somewhere a recommended list of generally most
useful debug options that only have a moderate performance impact? I'd
be happy to use a set of useful debug flags that generally impacts
performance by, say, <10%, on the computers I use for my everyday work
to help catch bugs. But it's sometimes quite hard to assess the impact
of different Kernel hacking options from just the description...

	Sami

--VV4b6MQE+OnNyhkM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCgAGBQJPrZFtAAoJEKLT589SE0a0GCIP/jZpnQE2qrN8YhTdYYmwjfQS
yNJ4VPbSeGPLALu7cRWS1sFoPLRgkTzHbUIPtG2SDJ/xFfiRzPzM81ENxPDcFJ2k
eiv+K3VE+Y6F2CMtcJOfd7mhOreGE28CmR8cn9z3ankbnHnDFXJ1RVwCXuxj7SJQ
USR3jiKBR9tevDCQUlbEE6ZX2e50XYen3rAOIPTgIqxAIqNyQ7f0kMSTJhPIeiEs
nBlaNe2P/LCDFk9+RnsxbUwbkUUpc3r2MsdXchybxVNNaF28Qm2AGwrIVGIrFjyC
FY308wDyh/l/b5sXIlHPlEN8TLgfm6q4G7Ai5wAWa3WQZ9oPvkXq5+lPi5I36jgu
QGcXcBogos0SZZUs8+GG+HCLU+bblmmLTQ3sdH2qg75KKm3InpJeXfqQMALfJj52
t+4Xlz/Sp2rW3NxwdB9UkS+h2ces0W7fgnTVE3DxGC3V2G2lbLgrhxP+ywssGMtA
BM4lbFMJzfVLg+1gB75GkQMNEI/BVfu2WTKRB6dHTs2Ih8+deJnsjAdlRUxXhVT+
JRKWXTJUfrBFAerHvO4LXK7s0nAlN8gcf6FOhZro/qfJCue1prmGlM9SJZHKAVdR
2K9npCtJUoDBX0nAo1eFNPbkZght+bU5xf0Sf7t8bfQyYxLVYqp/JQAWoHrCgoPC
r/M3ASnskzg5sXAX9EoV
=sabl
-----END PGP SIGNATURE-----

--VV4b6MQE+OnNyhkM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
