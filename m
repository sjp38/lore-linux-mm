Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7823A6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:22:33 -0400 (EDT)
Date: Wed, 12 Aug 2009 10:22:25 +0200
From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Page allocation failures in guest
Message-ID: <20090812102225.5a2e2305@mjolnir.ossman.eu>
In-Reply-To: <4A8272B2.3030309@redhat.com>
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>
	<20090811083233.3b2be444@mjolnir.ossman.eu>
	<4A811545.5090209@redhat.com>
	<200908121249.51973.rusty@rustcorp.com.au>
	<20090812081934.33e8280f@mjolnir.ossman.eu>
	<4A8272B2.3030309@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-5206-1250065356-0001-2"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-5206-1250065356-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 12 Aug 2009 10:43:46 +0300
Avi Kivity <avi@redhat.com> wrote:

> On 08/12/2009 09:19 AM, Pierre Ossman wrote:
> > Will it still trigger the OOM killer with this patch, or will things
> > behave slightly more gracefully?
> >   =20
>=20
> I don't think you mentioned the OOM killer in your original report?  Did=
=20
> it trigger?
>=20

I might have things backwards here, but I though the OOM killer started
doing its dirty business once you got that memory allocation failure
dump.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.ossman.eu-5206-1250065356-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkqCe8YACgkQ7b8eESbyJLj9hgCg86rzitLuQSw9vdaqxVRvfPkh
1dkAnAjP+OomDPfKMCevlAMJyAgmiZ/x
=uk06
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-5206-1250065356-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
