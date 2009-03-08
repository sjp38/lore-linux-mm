Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CF3786B00A7
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 11:54:12 -0400 (EDT)
Date: Sun, 8 Mar 2009 16:54:03 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090308165403.4d85da50@mjolnir.ossman.eu>
In-Reply-To: <20090308123825.GA25172@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090307141316.85cb1f62.akpm@linux-foundation.org>
	<20090308110006.0208932d@mjolnir.ossman.eu>
	<20090308113619.0b610f31@mjolnir.ossman.eu>
	<20090308123825.GA25172@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-24440-1236527646-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-24440-1236527646-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

I've gone through the dumps now, and still no meaningful difference.
All the big bootmem allocations are present in both kernels, and the
remaining memory in initcall is also the same for both (and doesn't
really decrease by any meaningful amount).

I also tried booting with init=3D/bin/sh, and the lost memory is present
even at that point.

More ideas?

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-24440-1236527646-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkmz6h4ACgkQ7b8eESbyJLjEEwCg+8ZvV0psHc9gEdo9T9NqOSh2
hewAoL65KUiHLfx5fataTyGPeAKyYsMu
=W+1d
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-24440-1236527646-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
