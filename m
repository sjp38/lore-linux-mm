Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5732A6B0352
	for <linux-mm@kvack.org>; Wed, 16 May 2018 14:51:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c4-v6so1626635qtp.9
        for <linux-mm@kvack.org>; Wed, 16 May 2018 11:51:51 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id j20-v6si165843qvm.114.2018.05.16.11.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 11:51:49 -0700 (PDT)
Message-ID: <1526496699.7898.10.camel@surriel.com>
Subject: Re: [PATCH] mm: fix nr_rotate_swap leak in swapon() error case
From: Rik van Riel <riel@surriel.com>
Date: Wed, 16 May 2018 14:51:39 -0400
In-Reply-To: <b6fe6b879f17fa68eee6cbd876f459f6e5e33495.1526491581.git.osandov@fb.com>
References: 
	<b6fe6b879f17fa68eee6cbd876f459f6e5e33495.1526491581.git.osandov@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-gkd6ccQFMr2LCtBOYgpS"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, kernel-team@fb.com


--=-gkd6ccQFMr2LCtBOYgpS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2018-05-16 at 10:56 -0700, Omar Sandoval wrote:
> From: Omar Sandoval <osandov@fb.com>
>=20
> If swapon() fails after incrementing nr_rotate_swap, we don't
> decrement
> it and thus effectively leak it. Make sure we decrement it if we
> incremented it.

My first inclination when reading this patch was
"surely there must be a better way to structure
the error code", but given that swap on rotating
media increments this count, while swap on SSD
does not, and the rotating media and SSD code
paths are 90% the same, my first inclination
was wrong.

Thanks for catching and fixing that bug.

> Fixes: 81a0298bdfab ("mm, swap: don't use VMA based swap readahead if
> HDD is used as swap")
> Signed-off-by: Omar Sandoval <osandov@fb.com>

Reviewed-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.
--=-gkd6ccQFMr2LCtBOYgpS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlr8fbsACgkQznnekoTE
3oM97wf+OrCO0DehyyqjC9eXzv/zkG7RHnGqVZaA17LWDGq5pJkgYHhPLxHqeDmY
5LbpVKRJ96nvImi7k0kNug9uAXx/JeepqIb2SUKimjuVu+yuV1Ta145dCbU6lP5f
3jCeMBKug9LK8HAS6yLd0GOWE14S9TKqP0LyQw8UyuAXyNkG5uiK+rkNhdOAh+47
vtmTGKNDdqp8cjI9ao2Jb4w1D0WBjeD+fpx2+OEjvJalskwROouhcBwsIIuvM/Mn
sWYoc7ITScSJIM2fwiMN5/EGSwTLBwiiU4QLCIgILIeD1eM6dJVp5sK83b3izjZ9
UEdf7UCX9iyXkoIx4XT76XxmHvMOoA==
=OHEh
-----END PGP SIGNATURE-----

--=-gkd6ccQFMr2LCtBOYgpS--
