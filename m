Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9935C6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 22:48:45 -0500 (EST)
Date: Wed, 15 Dec 2010 14:48:35 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Cross compilers (Was: Re: [PATCH] Fix unconditional GFP_KERNEL
 allocations in __vmalloc().)
Message-Id: <20101215144835.adf2078f.sfr@canb.auug.org.au>
In-Reply-To: <1292381600.2994.6.camel@oralap>
References: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com>
	<1292381600.2994.6.camel@oralap>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__15_Dec_2010_14_48_35_+1100_H/o3ZMV9DEJ4sqjh"
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, andreas.dilger@oracle.com, behlendorf1@llnl.gov, tony@bakeyournoodle.com
List-ID: <linux-mm.kvack.org>

--Signature=_Wed__15_Dec_2010_14_48_35_+1100_H/o3ZMV9DEJ4sqjh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Ricardo,

On Wed, 15 Dec 2010 03:53:20 +0100 "Ricardo M. Correia" <ricardo.correia@or=
acle.com> wrote:
>
> Since I have done all these changes manually and I don't have any
> non-x86-64 machines, it's possible that I may have typoed or missed
> something and that this patch may break compilation on other
> architectures or with other config options.
>=20
> Any suggestions are welcome.

See http://kernel.org/pub/tools/crosstool/files/bin

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__15_Dec_2010_14_48_35_+1100_H/o3ZMV9DEJ4sqjh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNCDqTAAoJEDMEi1NhKgbsXfYH/irDQMvSgk3UaSRCWoP8JlhJ
ZQ1rzPQ0yYfGmHxaWYuZ14mCWM65CLOdKnmFfzabrVL47/fm6B0Ntzg51DI2ZxzA
iIRweSPfN/wRHlPiSxlTCYHskR26FymBUKozxKuuMMi9BZJPlBqnO67GT/gT+8Kv
fFxMi9Kg6EggvwxyYJ/u7kYaOjOpsXXmh+PNjV2oCNl9Vt5yd4Pn4qnllnN37Z+h
THGprlxk3+6x+2nvP3d+/6LTq5NiAJyO7A6rvC7Ek48Hz6bfZzddNFV8mC37xuiX
czQNknphi4HaJR1Cf2qHyPwAs20VstDEwAuJH6Igr6CfkfQjqqqxZELcvtBbwDk=
=xiZ/
-----END PGP SIGNATURE-----

--Signature=_Wed__15_Dec_2010_14_48_35_+1100_H/o3ZMV9DEJ4sqjh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
