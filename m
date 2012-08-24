Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 975FF6B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:46:43 -0400 (EDT)
Received: by eeke49 with SMTP id e49so872433eek.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:46:42 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: fix alignment requirements for contiguous regions
In-Reply-To: <1345792810-5152-1-git-send-email-m.szyprowski@samsung.com>
References: <1345792810-5152-1-git-send-email-m.szyprowski@samsung.com>
Date: Fri, 24 Aug 2012 18:46:34 +0200
Message-ID: <xa1ttxvs2q6t.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Marek Szyprowski <m.szyprowski@samsung.com> writes:
> Contiguous Memory Allocator requires each of its regions to be aligned
> in such a way that it is possible to change migration type for all
> pageblocks holding it and then isolate page of largest possible order from
> the buddy allocator (which is MAX_ORDER-1). This patch relaxes alignment
> requirements by one order, because MAX_ORDER alignment is not really
> needed.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  drivers/base/dma-contiguous.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index 78efb03..34d94c7 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -250,7 +250,7 @@ int __init dma_declare_contiguous(struct device *dev,=
 unsigned long size,
>  		return -EINVAL;
>=20=20
>  	/* Sanitise input arguments */
> -	alignment =3D PAGE_SIZE << max(MAX_ORDER, pageblock_order);
> +	alignment =3D PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
>  	base =3D ALIGN(base, alignment);
>  	size =3D ALIGN(size, alignment);
>  	limit &=3D ~(alignment - 1);


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
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQN6/qAAoJECBgQBJQdR/0cdIP/iefsLh1o+XolmGZH2R67hAE
Ktci7O0fFlwg0D6fgE2D/tmsLbYZFuSLGWbjWvb0I4tKMuleDSryH3P1AYN8uD3K
NYhwGHeyvwCNtn0QQ3bHL17ScanefZBmBOxnIi6wDWlvS54CFQJFCqSbSGYGoUq/
5mJpxnTlT/+3g0WB/SEMN9L1VPe51aGnvTK8scX4KP263yAQa9CTKgaOuMW/jAPy
wELs+3YyR/zRdKNr8Ay+E5YhpXAoIHbm2RucQpLZTFmC05bCxBO6LmkDx7EYnf1g
GHwt0Jp9OtrK/eTOgszu2bJ4S+ruieQKhN6pjPxnwAfc5r3AxN8qA6YfiiKV/9zs
Tb12vbBhCRtsGjEFZcTL9d2LFX64jy7rqPEERM1s0A/7Q3+o18z4/GyFv4dODsoy
4omv1cqKTsz7odieVATVf5hksIdmdH97KT2KXdpP7u2J0DjQgf/xyPg1SKCIO8B1
eChM6rgk0b+KPABXWv6yz+0iYXwbEhTidmThvODRY/q8npXFSTIRKkxQzVRVN6oe
BB5505gRj5hXa/6JVaw+TZeiJn4wO/ymdAgTYvcvd9/fh2I9tfn4+yuk2G+hm7KH
sOFlS+Mq2Nxf9TALSeXQemgnm0BF8nQjEQN2dbttansvtz7PRNUApEVqbOCOh7Kv
KZ30NJoHGHGAdbMQTw+p
=BLh2
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
