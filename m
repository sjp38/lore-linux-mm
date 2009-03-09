Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB0F46B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 11:02:33 -0400 (EDT)
Date: Mon, 9 Mar 2009 16:02:16 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090309160216.2048e898@mjolnir.ossman.eu>
In-Reply-To: <20090309142241.GA4437@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090309013742.GA11416@localhost>
	<20090309020701.GA381@localhost>
	<20090309084045.2c652fbf@mjolnir.ossman.eu>
	<20090309142241.GA4437@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-6517-1236610941-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-6517-1236610941-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 9 Mar 2009 22:22:41 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

>=20
> Thanks for the data! Now it seems that some pages are totally missing
> from bootmem or slabs or page cache or any application consumptions...
>=20

So it isn't just me that's blind. That's something I guess. :)

> Will searching through /proc/kpageflags for reserved pages help
> identify the problem?
>=20
> Oh kpageflags_read() does not include support for PG_reserved:
>=20

I can probably hack together something that outputs the served pages.
Anything else that is of interest?

> > DirectMap2M:  18446744073709551613
>=20
> This field looks weird.
>=20

Sorry, red herring. I'm in the middle of a bisect and that particular
old bug happened to surface. It was not present with the releases
2.6.27.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-6517-1236610941-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm1L3sACgkQ7b8eESbyJLgIUgCdGF4WlRDERf8mB11qWN18Ds6U
EJQAn0BWyF0xIXJ4+hdLi45GbDYX56w6
=I2iu
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-6517-1236610941-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
