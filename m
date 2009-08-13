Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62DC16B004D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 16:25:50 -0400 (EDT)
Date: Thu, 13 Aug 2009 22:25:48 +0200
From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Page allocation failures in guest
Message-ID: <20090813222548.5e0743dd@mjolnir.ossman.eu>
In-Reply-To: <200908121501.53167.rusty@rustcorp.com.au>
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>
	<4A811545.5090209@redhat.com>
	<200908121249.51973.rusty@rustcorp.com.au>
	<200908121501.53167.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-22484-1250195153-0001-2"
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-22484-1250195153-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 12 Aug 2009 15:01:52 +0930
Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Wed, 12 Aug 2009 12:49:51 pm Rusty Russell wrote:
> > On Tue, 11 Aug 2009 04:22:53 pm Avi Kivity wrote:
> > > On 08/11/2009 09:32 AM, Pierre Ossman wrote:
> > > > I doesn't get out of it though, or at least the virtio net driver
> > > > wedges itself.
> >=20
> > There's a fixme to retry when this happens, but this is the first report
> > I've received.  I'll check it out.
>=20
> Subject: virtio: net refill on out-of-memory
>=20
> If we run out of memory, use keventd to fill the buffer.  There's a
> report of this happening: "Page allocation failures in guest",
> Message-ID: <20090713115158.0a4892b0@mjolnir.ossman.eu>
>=20
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>=20

Patch applied. Now we wait. :)

--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.ossman.eu-22484-1250195153-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkqEdtAACgkQ7b8eESbyJLiSPwCgybA1a1vbQ+FPw6x+8eHmHU6c
X8QAoNy9Ic7yQfwH5H6d8M+IFdO95W1M
=j4TS
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-22484-1250195153-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
