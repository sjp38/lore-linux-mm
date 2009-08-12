Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D9A046B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 02:19:39 -0400 (EDT)
Date: Wed, 12 Aug 2009 08:19:34 +0200
From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Page allocation failures in guest
Message-ID: <20090812081934.33e8280f@mjolnir.ossman.eu>
In-Reply-To: <200908121249.51973.rusty@rustcorp.com.au>
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>
	<20090811083233.3b2be444@mjolnir.ossman.eu>
	<4A811545.5090209@redhat.com>
	<200908121249.51973.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-3535-1250057980-0001-2"
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-3535-1250057980-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 12 Aug 2009 12:49:51 +0930
Rusty Russell <rusty@rustcorp.com.au> wrote:

>=20
> It's kind of the nature of networking devices :(
>=20
> I'd say your host now offers GSO features, so the guest allocates big
> packets.
>=20
> > > I doesn't get out of it though, or at least the virtio net driver
> > > wedges itself.
>=20
> There's a fixme to retry when this happens, but this is the first report
> I've received.  I'll check it out.
>=20

Will it still trigger the OOM killer with this patch, or will things
behave slightly more gracefully?

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.ossman.eu-3535-1250057980-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkqCXvsACgkQ7b8eESbyJLj8dwCgyJNVA/HvKHZRcWTNV2HHSoHc
obUAoPCiGgEIC8eYz09sJwwz0c741bns
=xvSg
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-3535-1250057980-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
