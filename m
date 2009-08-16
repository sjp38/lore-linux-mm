Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B437C6B0055
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 03:31:10 -0400 (EDT)
Date: Sun, 16 Aug 2009 17:31:01 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mm/ipw2200 regression (was: Re: linux-next: Tree for August 6)
Message-Id: <20090816173101.6e47b702.sfr@canb.auug.org.au>
In-Reply-To: <200908151856.48596.bzolnier@gmail.com>
References: <20090806192209.513abec7.sfr@canb.auug.org.au>
	<200908062250.51498.bzolnier@gmail.com>
	<200908071515.45169.bzolnier@gmail.com>
	<200908151856.48596.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sun__16_Aug_2009_17_31_01_+1000_+6c3MUXKSgOxtZ7o"
Sender: owner-linux-mm@kvack.org
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

--Signature=_Sun__16_Aug_2009_17_31_01_+1000_+6c3MUXKSgOxtZ7o
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Bart,

On Sat, 15 Aug 2009 18:56:48 +0200 Bartlomiej Zolnierkiewicz <bzolnier@gmai=
l.com> wrote:
>
> The bug managed to slip into Linus' tree..
>=20
> ipw2200: Firmware error detected.  Restarting.
> ipw2200/0: page allocation failure. order:6, mode:0x8020
> Pid: 945, comm: ipw2200/0 Not tainted 2.6.31-rc6-dirty #69
                                                   ^^^^^
So, this is rc6 plus what?  (just in case it is relevant).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sun__16_Aug_2009_17_31_01_+1000_+6c3MUXKSgOxtZ7o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqHtbUACgkQjjKRsyhoI8zhbQCZAVTfcWmZU0Dghmfh3ADZ2kL2
LyQAoLsN7Zd63GWHW1AZKHxsu/q5K43T
=UIR2
-----END PGP SIGNATURE-----

--Signature=_Sun__16_Aug_2009_17_31_01_+1000_+6c3MUXKSgOxtZ7o--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
