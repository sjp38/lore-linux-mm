Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 698436B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 15:58:33 -0400 (EDT)
Date: Tue, 10 Mar 2009 20:58:23 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310205823.661724b5@mjolnir.ossman.eu>
In-Reply-To: <20090310122210.GA8415@localhost>
References: <20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090309013742.GA11416@localhost>
	<20090309020701.GA381@localhost>
	<20090309084045.2c652fbf@mjolnir.ossman.eu>
	<20090309142241.GA4437@localhost>
	<20090309160216.2048e898@mjolnir.ossman.eu>
	<20090310024135.GA6832@localhost>
	<20090310081917.GA28968@localhost>
	<20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-20726-1236715107-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-20726-1236715107-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Ok, I think I've found some, but not all of the missing memory.

I had to remove PG_swapbacked and PG_private2 as 2.6.26/2.6.27 didn't
have those bits.

After that, a comparison shows that this row is in 2.6.27, but not
2.6.26:

0x00020	     20576       80  _____l____________  lru

Unfortunately there are about 170 MB of missing memory, not 80. So we
probably need to dig deeper. But does the above say anything to you?

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-20726-1236715107-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm2xmIACgkQ7b8eESbyJLimbACeMdvL2ymkPHdU1Xkvhjh06oq9
A3MAnRJbQD3UoQOoQ8PIZHtb9TaspZMW
=Ozbe
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-20726-1236715107-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
