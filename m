Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id AA2ED6B0098
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:52:20 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hm6so2014014wib.8
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 08:52:19 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: use migrate_prep() instead of migrate_prep_local()
In-Reply-To: <1352708989-25359-1-git-send-email-m.szyprowski@samsung.com>
References: <1352708989-25359-1-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 12 Nov 2012 17:52:11 +0100
Message-ID: <xa1t625azrus.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, SeongHwan Yoon <sunghwan.yun@samsung.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 12 2012, Marek Szyprowski wrote:
> __alloc_contig_migrate_range() should use all possible ways to get all the
> pages migrated from the given memory range, so pruning per-cpu lru lists
> for all CPUs is required, regadless the cost of such operation. Otherwise
> some pages which got stuck at per-cpu lru list might get missed by
> migration procedure causing the contiguous allocation to fail.
>
> Reported-by: SeongHwan Yoon <sunghwan.yun@samsung.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1bfe2b0..fcb9719 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5677,7 +5677,7 @@ static int __alloc_contig_migrate_range(struct comp=
act_control *cc,
>  	unsigned int tries =3D 0;
>  	int ret =3D 0;
>=20=20
> -	migrate_prep_local();
> +	migrate_prep();
>=20=20
>  	while (pfn < end || !list_empty(&cc->migratepages)) {
>  		if (fatal_signal_pending(current)) {

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQoSk7AAoJECBgQBJQdR/09NcP/15Ve5P9jOlCH3LpZZkRAjRD
e24MCnmkrj/SGaped1F2rW3nZr/Qb2lZtKHwYXcrU+qj2O3Ndj/Iz80eW4ywVnVi
QOqzDKwfBi0lapCtZjyCsiyrmsR/eKJ8aH1wNtQzMBUEqkqHKniBXyeJ5+ARlVFV
WHKljHOPAlH8XIOdggumWAEKWuJGnJg9uRIRrAWSB0dWsjLCTLOypB83QeqRzC2g
ACSuVnSk1fHmeaM7moFCahw5+nTta5HC99FAboSRLTVO3cfaew+Wxqzsy6Ld32ob
zzrvMTB/yV92v9FztgG6qpyEIfIxtcnx93AyrFEs2xcKIpL2lf/rzmBBQmB2rMX9
2b2oJWqRyqZ2I4iOfxfvG+xcXmRCry7mN4j/6cdDV8/KR/NXFkm8kC4PgjGguqs7
wRXKeSGLjssOkU1Zo4Yvx2RW/TY4txav6Jl3nWRvmwhY47z9YkZrm8K4J+yvC71h
n1+u2TIT2dpkJSCInNICICwTsid4b8WgnKZK47rgNtPK1reUJlkVJSjizhRwOs/o
feLi+xYOzNLQ794MT+EgmykUMVSZoPzZ5gBQn8/YIz8ByQPUbkX0NjM0fq2ab+rM
PuEilIxWoyQonKhSx5Dh7gK7Kd/duv9+pkZ2KUsr69SXTL3qrABbImYUPSez9hxw
firzZ5iyjnv6zdXHEMLS
=s8Xa
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
