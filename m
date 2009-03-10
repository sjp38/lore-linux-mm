Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD7DD6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 11:52:52 -0400 (EDT)
Date: Tue, 10 Mar 2009 16:52:41 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310165241.7d912bfa@mjolnir.ossman.eu>
In-Reply-To: <20090310131155.GA9654@localhost>
References: <20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090309013742.GA11416@localhost>
	<20090309020701.GA381@localhost>
	<20090309084045.2c652fbf@mjolnir.ossman.eu>
	<20090309142241.GA4437@localhost>
	<20090309160216.2048e898@mjolnir.ossman.eu>
	<20090310024135.GA6832@localhost>
	<20090310081917.GA28968@localhost>
	<20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
	<20090310131155.GA9654@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-18933-1236700366-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-18933-1236700366-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

My bisect has ran into a wall. I cannot run any of the intermediate
kernels that are left. I could try reverting the commits one at a time,
but I'll take a break and test your code here. Now we just have to wait
for the kernel to compile. :)

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-18933-1236700366-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm2jMsACgkQ7b8eESbyJLiHcQCgvuAH3sATSVj5Yu0CbvBlNAKn
oYwAniLbZPVagMfUgPLrweEsqu8kzYsW
=/OR6
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-18933-1236700366-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
