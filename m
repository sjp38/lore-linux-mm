Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B70156B0092
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:54:43 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y10so3139984wgg.2
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:54:43 -0800 (PST)
Received: from multi.imgtec.com (multi.imgtec.com. [194.200.65.239])
        by mx.google.com with ESMTPS id or5si4145537wjc.93.2013.12.09.01.54.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Dec 2013 01:54:42 -0800 (PST)
Message-ID: <52A5935A.4040709@imgtec.com>
Date: Mon, 9 Dec 2013 09:54:34 +0000
From: James Hogan <james.hogan@imgtec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com>
In-Reply-To: <52A53024.9090701@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="TBnT1kX28txvQICNnkDoM0RxVmi0PACcv"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--TBnT1kX28txvQICNnkDoM0RxVmi0PACcv
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/12/13 02:51, Chen Gang wrote:
> Recommend to add default case to avoid compiler's warning, although at
> present, the original implementation is still correct.
>=20
> The related warning (with allmodconfig for metag):
>=20
>     CC      mm/zswap.o
>   mm/zswap.c: In function 'zswap_writeback_entry':
>   mm/zswap.c:537: warning: 'ret' may be used uninitialized in this func=
tion
>=20
>=20
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/zswap.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 5a63f78..bfd1807 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -585,6 +585,8 @@ static int zswap_writeback_entry(struct zbud_pool *=
pool, unsigned long handle)
> =20
>  		/* page is up to date */
>  		SetPageUptodate(page);
> +	default:
> +		BUG();

This doesn't hide the warning when CONFIG_BUG=3Dn since BUG() optimises
out completely.

Since the metag compiler is stuck on an old version (gcc 4.2.4), which
is wrong to warn in this case, and newer versions of gcc don't appear to
warn about it anyway (I just checked with gcc 4.7.2 x86_64), I have no
objection to this warning remaining in the metag build.

Cheers
James


--TBnT1kX28txvQICNnkDoM0RxVmi0PACcv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJSpZNhAAoJEKHZs+irPybfE8UP/jRC8/+2v6GI8UFDyL9Vj81Y
GhtBn5KgZ4SQ7Yfws6AFtYlLt2WgNblZc9j0eJPq9VlOpBGO8c/qhmvDWYLUAYqx
KC6Z/E8Q1QkBH0VEBYO1ierUw6KEUTXjb2vz55Mjd5UbHrY1XZhTlq69s74GX3vr
28k4AX/FqTwPX5CkLz3zEfukqy80KeATqFX3iAqVDYu8Ri6efydctvYNgVPXpVq5
Cf16znaT+o4wXcAj2BMYPhS9o57BzvxBr4WE7hW8j5SuqGltycvsCaAHMi/06ZjJ
J8YxHDqvoVx7dwPhPPMzvu0VwxgGMcG0DTlPCB1FVv0GLYvmLGL1/oRO8v8DBDit
SC5g5WstLcUdfBdqtXijCdTjpSlrgKIG5sbRquSfrEF9MUR05cazuREz8zzbtR5g
JMcGBB9fqbrgAJFgzptGbFRieWK62u/3uMr5s+UcLG4JRErmWf2bqe4hRt9D/Rv5
I47/b2kfIU1U7M9Bl8/a+nVy8nAL7mbKZi5MeDEFpOSpW27rZWU+aFTCLPK707LH
r4U00p4aEdsYRHsRZU+Wb0xyAbtICP7YF16Q1k5AcvVQy/bLFgj4K7xPf0rPtLqV
i48fITTZAD5GLF33eFu4E4F0bNUFBdahQzjV8nqsCWNl0J+ByFl+F/J1UxPwoOzE
sP94u2PHNKUi5sgquguM
=1+3r
-----END PGP SIGNATURE-----

--TBnT1kX28txvQICNnkDoM0RxVmi0PACcv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
