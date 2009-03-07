Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE8EA6B009D
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 17:53:11 -0500 (EST)
Date: Sat, 7 Mar 2009 23:53:01 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090307235301.045dd93a@mjolnir.ossman.eu>
In-Reply-To: <20090307141316.85cb1f62.akpm@linux-foundation.org>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090307141316.85cb1f62.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-4191-1236466385-0001-2"
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-4191-1236466385-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 7 Mar 2009 14:13:16 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

>=20
> Below is a super-quick hackport of that patch into 2.6.26.  That will
> allow us (ie: you ;)) to compare bootmem allocations between the two
> kernels.
>=20

Compiling...

I take it you couldn't see anything like this in your end?

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-4191-1236466385-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkmy+tAACgkQ7b8eESbyJLj+YQCePmlKp5ZJJ6xSiNf3CuxEzQQP
r7UAn3flsfNonpRvbKNJ0G6IkrRCJ/ys
=0DpM
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-4191-1236466385-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
