Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 459376B004D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:40:32 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so4913557wgb.26
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 10:40:30 -0700 (PDT)
From: Michal Nazarewicz <mina86@tlen.pl>
Subject: Re: [PATCH 1/3] mm: correct return value of migrate_pages()
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
Date: Mon, 16 Jul 2012 19:40:09 +0200
In-Reply-To: <1342455272-32703-1-git-send-email-js1304@gmail.com> (Joonsoo
	Kim's message of "Tue, 17 Jul 2012 01:14:30 +0900")
Message-ID: <874np7r4ee.fsf@erwin.mina86.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

--=-=-=
Content-Transfer-Encoding: quoted-printable

Joonsoo Kim <js1304@gmail.com> writes:
> migrate_pages() should return number of pages not migrated or error code.
> When unmap_and_move return -EAGAIN, outer loop is re-execution without
> initialising nr_failed. This makes nr_failed over-counted.
>
> So this patch correct it by initialising nr_failed in outer loop.
>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

Actually, it makes me wonder if there is any code that uses this
information.  If not, it would be best in my opinion to make it return
zero or negative error code, but that would have to be checked.

> diff --git a/mm/migrate.c b/mm/migrate.c
> index be26d5c..294d52a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -982,6 +982,7 @@ int migrate_pages(struct list_head *from,
>=20=20
>  	for(pass =3D 0; pass < 10 && retry; pass++) {
>  		retry =3D 0;
> +		nr_failed =3D 0;
>=20=20
>  		list_for_each_entry_safe(page, page2, from, lru) {
>  			cond_resched();

=2D-=20
Best regards,                                          _     _
 .o. | Liege of Serenly Enlightened Majesty of       o' \,=3D./ `o
 ..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
 ooo +-<mina86-mina86.com>-<jid:mina86-jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQBFH6AAoJECBgQBJQdR/0/SsP+gK/qMIWoDDSiGjtDXaBHGU8
QT3FPyIXFAyHE9VrIAz5lQI9N/Xk5oq52o8Eu3nKpEhbUgLMxN6dFADe4NKzZJ4H
xyPFDWWe+LDGsGzHtxgrp7SL2bnIMnAU5JupD4X1yLSIV1BW0j79zBW16ablD87R
auH0xZ6A6ygVyGNpqNskqzTktphr1Uh53IiIbCtUNyo2SMwSA6nXLe3vsc8bWb00
oOlrUf0OWSrcXsTHTOuWWPfxEaUitr2CXglpfzHmVPG7vVBJTRz0X3RQ+yAEJg4u
re3ZDHlgt42j45MOM0+j23EQxpF0MeZcT/+p9qvu0rnF/GEawGVTT9SjUK/zG09H
bO409BdBBjCxAzl2FX+ykYYShwLbb5G5ieLklodf0ZnvpgWrHeQ1GdtlsipCD9Xm
6elS2ROksY9tnKdXiI0quw6K1Uke8ovT0Ijqrchz5yt7RyA9nMPz/ESbdPJAnt/1
WJm2oFKAh0bvBJg5tA8pRH9O9SuX+wHXwSkg0Ii2xMZxIj1oAKfPiX+MhfQhUoea
wIxHSkLOn0ONiLy1kw7v0iTVXDEpj616niElP3vPe4TIUniIP+vnnr+PC2j3ZhAp
qqO3x0F6Mfho1aWD+NnTkF/5rCSaJCg36psfjSsRXSM5zHgjxpn47WsTrOQYyiS/
NR0hxTDMYVwuf/WNU1/d
=zdx2
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
