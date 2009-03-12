Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F3D356B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 02:50:23 -0400 (EDT)
Date: Thu, 12 Mar 2009 07:50:04 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090312075004.059feb5e@mjolnir.ossman.eu>
In-Reply-To: <20090311224353.166887c9@mjolnir.ossman.eu>
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
	<20090311174638.2e964c0b@mjolnir.ossman.eu>
	<20090311224353.166887c9@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-6157-1236840609-0001-2"
Sender: owner-linux-mm@kvack.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-6157-1236840609-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Mar 2009 22:43:53 +0100
Pierre Ossman <drzeus@drzeus.cx> wrote:

>=20
> I'll reconfigure it to use piix tomorrow and see if I can get it
> running.
>=20

No dice. In both cases (virtio_blk and piix), it sees the disk and
reads the partitions, but then fails to find any volume groups. Does
this ring any bells?

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-6157-1236840609-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm4sJ8ACgkQ7b8eESbyJLh+PQCfQwTDWHDNlSEvjeMUHvRmeuQ9
FhsAni4hiJwb9mosW6AJ8YSlEbqcmXW8
=Ln84
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-6157-1236840609-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
