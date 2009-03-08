Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EBF216B00A1
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 06:36:28 -0400 (EDT)
Date: Sun, 8 Mar 2009 11:36:19 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090308113619.0b610f31@mjolnir.ossman.eu>
In-Reply-To: <20090308110006.0208932d@mjolnir.ossman.eu>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090307141316.85cb1f62.akpm@linux-foundation.org>
	<20090308110006.0208932d@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-19852-1236508583-0001-2"
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-19852-1236508583-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 8 Mar 2009 11:00:06 +0100
Pierre Ossman <drzeus@drzeus.cx> wrote:

>=20
> I'm having problems booting this machine on a vanilla 2.26.6. Fedora's
> kernel works nice though, so I guess they have a bug fix for this. I've
> attached a screenshot in case it rings any bells.
>=20

It turns out it's your backported patch that's the problem. I'll see if
I can get it working. :)

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-19852-1236508583-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkmzn6YACgkQ7b8eESbyJLhnZACdFJmwpB9mE5vi7PZBZye90FDl
r7gAnjoBjgGntaMPVBkYBgT4d3PiwWps
=1O+5
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-19852-1236508583-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
