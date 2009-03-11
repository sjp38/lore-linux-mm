Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D0F2B6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 03:22:26 -0400 (EDT)
Date: Wed, 11 Mar 2009 08:22:13 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311082213.44ba65e0@mjolnir.ossman.eu>
In-Reply-To: <20090311091738.8784.A69D9226@jp.fujitsu.com>
References: <20090310081917.GA28968@localhost>
	<20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090311091738.8784.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-26672-1236756140-0001-2"
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-26672-1236756140-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Mar 2009 09:19:32 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

>=20
> Can you try to turn off CONFIG_FTRACE* build option?
>=20

That's just it, it is off.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-26672-1236756140-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm3ZqgACgkQ7b8eESbyJLhmtACfWxQxbWmyt0n87mEFrZETnpxU
iL0AoLXaUcucLqMgq7/zy+SQjVOgo2Xg
=B0i5
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-26672-1236756140-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
