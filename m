Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC8576B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:28:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so9482150pge.5
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 01:28:40 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id p17si21059490pfi.66.2017.01.16.01.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 01:28:40 -0800 (PST)
Date: Mon, 16 Jan 2017 11:28:40 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Message-ID: <20170116092840.GC32481@mtr-leonro.local>
References: <20170116091643.15260-1-bp@alien8.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="lCAWRPmW1mITcIfM"
Content-Disposition: inline
In-Reply-To: <20170116091643.15260-1-bp@alien8.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--lCAWRPmW1mITcIfM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 16, 2017 at 10:16:43AM +0100, Borislav Petkov wrote:
> From: Borislav Petkov <bp@suse.de>
>
> We wanna know who's doing such a thing. Like slab.c does that.
>
> Signed-off-by: Borislav Petkov <bp@suse.de>
> ---
>  mm/slub.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 067598a00849..1b0fa7625d6d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1623,6 +1623,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>  		flags &= ~GFP_SLAB_BUG_MASK;
>  		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
>  				invalid_mask, &invalid_mask, flags, &flags);
> +		dump_stack();

Will it make sense to change these two lines above to WARN(true, .....)?

>  	}
>
>  	return allocate_slab(s,
> --
> 2.11.0
>

--lCAWRPmW1mITcIfM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh8kkcACgkQ5GN7iDZy
WKfYuhAApFfofFIU7vuBSuz6np7vAmzyYml2kLuuZuzhG2FC7aDOALyqrLwdSEuz
zmSQ6y1nua3NakwP5cG+K//PNaZ3+6uqheTG71gj6bb6LtswKWl2VRGbCmiJZmd4
wCogeKjqvQi0wwfd1gA3Ly7FMFZMwOdb+luNOnYY7Z0rp6wLVJCPw+Cez7MBpqcZ
yOutkbGqbYhPJ8MWi1JzYj6V/DJ1+RQqe8wEAdJ2zB1GYwPU8ypRKShyDDczg7Mf
+Tk9aV6r47RX7csS4qb9ZKebeoRdBSlT2CqKULoNqTBELlcOwuXbrATr/PuhT074
G+qWxdwq6eoN0irwP+ySokBNJIle2w/k1hjjx7FkiWngxxHTOXCiyeNw2antgQlG
yFluQurX7ApvxswuIguoTd7GHyzexq14F7Go3SXv8gLti2rXqTug7MUaSuQmQvEW
8nJVfI843CEWBHS/QxClBaPqqqnJ4IzYYT6PJ4tZtFBAjiH+792gqDSW0uSHP/tm
LLxqiO2yYDf/wBqh1EjZoTTm2Di93jrrFb/ZrsDi5IEKbdLtPe+xQqjeUmLMvMxD
FEMMl9VvOKlQ0FHmvYSpT07xkdA+HMqKWa/TtJqPq+wm0QDwbFvxy/cILZTm0IUx
YcdYgHRwKfoNHlivbnmtH1C3jOClaWqBO5wd+DHVDyN4MHxUslQ=
=+zKe
-----END PGP SIGNATURE-----

--lCAWRPmW1mITcIfM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
