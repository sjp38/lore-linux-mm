Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7126B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 12:46:49 -0400 (EDT)
Date: Wed, 11 Mar 2009 17:46:38 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311174638.2e964c0b@mjolnir.ossman.eu>
In-Reply-To: <alpine.DEB.2.00.0903111115010.3062@gandalf.stny.rr.com>
References: <20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
	<20090310131155.GA9654@localhost>
	<20090310212118.7bf17af6@mjolnir.ossman.eu>
	<20090311013739.GA7078@localhost>
	<20090311075703.35de2488@mjolnir.ossman.eu>
	<20090311071445.GA13584@localhost>
	<20090311082658.06ff605a@mjolnir.ossman.eu>
	<20090311073619.GA26691@localhost>
	<20090311085738.4233df4e@mjolnir.ossman.eu>
	<20090311130022.GA22453@localhost>
	<20090311160223.638b4bc9@mjolnir.ossman.eu>
	<alpine.DEB.2.00.0903111115010.3062@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-31191-1236790003-0001-2"
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-31191-1236790003-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Mar 2009 11:47:16 -0400 (EDT)
Steven Rostedt <rostedt@goodmis.org> wrote:

>=20
> BTW, which kernel are you testing?  2.6.27, ftrace had its own special=20
> buffering system. It played tricks with the page structs of the pages in=
=20
> the buffer. It used the lru parts of the pages to link list itself.
> I just booted on a straight 2.6.27 with tracing configured.
>=20

I've been primarily testing 2.6.27, yes. I think I tested 2.6.29-rc7 at
the beginning of this, but my memory is a bit fuzzy so I better retest.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-31191-1236790003-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm36vAACgkQ7b8eESbyJLh6vACggHvoj19x7ppJnBcnLSwphdSJ
sAkAnjP4U1uIoPFGiQD6XkqNHZ6gqjP0
=euqX
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-31191-1236790003-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
