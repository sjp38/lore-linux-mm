Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 04CED6B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 20:23:48 -0400 (EDT)
Date: Thu, 4 Aug 2011 10:23:37 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH -mmotm] media: video/adp1653.c needs module.h
Message-Id: <20110804102337.7a91f4d91d887ccd0168e4f8@canb.auug.org.au>
In-Reply-To: <20110803101226.0d17b23e.rdunlap@xenotime.net>
References: <201108022357.p72NvsZM022462@imap1.linux-foundation.org>
	<20110803101226.0d17b23e.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__4_Aug_2011_10_23_37_+1000_.lv._/j8Qp6KHUCM"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: akpm@linux-foundation.org, linux-media@vger.kernel.org, mchehab@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

--Signature=_Thu__4_Aug_2011_10_23_37_+1000_.lv._/j8Qp6KHUCM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Randy,

On Wed, 3 Aug 2011 10:12:26 -0700 Randy Dunlap <rdunlap@xenotime.net> wrote:
>
> From: Randy Dunlap <rdunlap@xenotime.net>
>=20
> adp1653.c uses interfaces that are provided by <linux/module.h>
> and needs to include that header file to fix build errors.
>=20
> drivers/media/video/adp1653.c:453: warning: data definition has no type o=
r storage class
> drivers/media/video/adp1653.c:453: warning: parameter names (without type=
s) in function declaration
> drivers/media/video/adp1653.c:474: error: 'THIS_MODULE' undeclared (first=
 use in this function)
> and more.
>=20
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

That is a bug that is now in Linus' tree and this fix is pending in the
moduleh tree in linux-next.  So this patch should go to Linus.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__4_Aug_2011_10_23_37_+1000_.lv._/j8Qp6KHUCM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOOeaJAAoJEDMEi1NhKgbs87UH/30egYvPcRfZQ3gF+enSutHA
sqn+pfBMKC9inTWgoQG+Fexryg2KHU9XDEMox7sXFtlj16nHdZB6yQ/wNoGusbLc
FSjUIjIIYdE99Xr2WfXXVSa8qjV77OWvq4/FHxgTtoIE1ZHJxcyHrG31M7sxj1K0
LPJQrRSM+XDrVnfl5L0Q/Yza3Z5t6Rv+YvpVzAiLL2VI/iXxDfgUc0XX0mfAzRT/
FDpC68KIoMVKEeSQonKI+bbnLY721kE0A28Fdw4QrTLXq1byXzhmlyA6d33WwiS+
wmxjeFf/HZoBbNAgGlohRRVwBzXJrXXFs/af0BuCcNbL+b4qkAXsA7gNzHypSYs=
=PorZ
-----END PGP SIGNATURE-----

--Signature=_Thu__4_Aug_2011_10_23_37_+1000_.lv._/j8Qp6KHUCM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
