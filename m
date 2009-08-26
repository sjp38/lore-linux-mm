Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AFC946B0125
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 00:55:05 -0400 (EDT)
Date: Wed, 26 Aug 2009 06:55:01 +0200
From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Page allocation failures in guest
Message-ID: <20090826065501.7ab677b9@mjolnir.ossman.eu>
In-Reply-To: <200908261147.17838.rusty@rustcorp.com.au>
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>
	<200908121501.53167.rusty@rustcorp.com.au>
	<20090813222548.5e0743dd@mjolnir.ossman.eu>
	<200908261147.17838.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-655-1251262508-0001-2"
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-655-1251262508-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 26 Aug 2009 11:47:17 +0930
Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Fri, 14 Aug 2009 05:55:48 am Pierre Ossman wrote:
> > On Wed, 12 Aug 2009 15:01:52 +0930
> > Rusty Russell <rusty@rustcorp.com.au> wrote:
> > > Subject: virtio: net refill on out-of-memory
> ...=20
> > Patch applied. Now we wait. :)
>=20
> Any results?
>=20

It's been up for 12 days, so I'd say it works. But there is nothing in
dmesg, which suggests I haven't triggered the condition yet.

I wonder if there might be something broken with Fedora's kernel. :/
(I am running the same upstream version, and their conf, for this test,
but not all of their patches)

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.ossman.eu-655-1251262508-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkqUwCkACgkQ7b8eESbyJLhvfgCeJdWl6lSQa8Zi7CGsSLbjyr4x
1+EAnjLeYeg7bXuVqJ3AACXj23IMc+uk
=tuHm
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-655-1251262508-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
