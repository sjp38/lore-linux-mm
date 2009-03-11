Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0926B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 12:56:06 -0400 (EDT)
Date: Wed, 11 Mar 2009 17:55:56 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311175556.2a127801@mjolnir.ossman.eu>
In-Reply-To: <alpine.DEB.2.00.0903111022480.16494@gandalf.stny.rr.com>
References: <20090310024135.GA6832@localhost>
	<20090310081917.GA28968@localhost>
	<20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
	<20090310131155.GA9654@localhost>
	<20090310212118.7bf17af6@mjolnir.ossman.eu>
	<20090311013739.GA7078@localhost>
	<20090311075703.35de2488@mjolnir.ossman.eu>
	<20090311071445.GA13584@localhost>
	<20090311082658.06ff605a@mjolnir.ossman.eu>
	<20090311073619.GA26691@localhost>
	<alpine.DEB.2.00.0903111022480.16494@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-31232-1236790560-0001-2"
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-31232-1236790560-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Mar 2009 10:25:10 -0400 (EDT)
Steven Rostedt <rostedt@goodmis.org> wrote:

>=20
> The ring buffer is allocated at start up (although I'm thinking of making=
=20
> it allocated when it is first used), and the allocations are done percpu.=
=20
>=20
> It allocates around 3 megs per cpu. How many CPUs were on this box?
>=20

Is this per actual CPU though? Or per CONFIG_NR_CPUS? 3 MB times 64
equals roughly the lost memory. But then again, you said it was 10 MB
per CPU for 2.6.27...

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-31232-1236790560-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm37R8ACgkQ7b8eESbyJLiZ1gCcDq+EJwYimHQXQ/I8DL2z0IRB
ktIAnAjk00R4DSgcpJjyz1jvdfVI3wgV
=ctsG
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-31232-1236790560-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
