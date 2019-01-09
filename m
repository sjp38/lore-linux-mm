Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86A5D8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 09:10:00 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d31so6840406qtc.4
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 06:10:00 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id k3si4468317qvh.178.2019.01.09.06.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 06:09:58 -0800 (PST)
Message-ID: <a8d1cbfa03c9bf5f1eeaee7539dacc581df2dd97.camel@surriel.com>
Subject: Re: [PATCH] mm,slab,memcg: call memcg kmem put cache with same
 condition as get
From: Rik van Riel <riel@surriel.com>
Date: Wed, 09 Jan 2019 09:09:49 -0500
In-Reply-To: <CALvZod6=-kdUk23i7eOr5AO-_2Fk_BmJiL3QjSJ4S4QOs0xKkw@mail.gmail.com>
References: <20190109040107.4110-1-riel@surriel.com>
	 <CALvZod6=-kdUk23i7eOr5AO-_2Fk_BmJiL3QjSJ4S4QOs0xKkw@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-BjQKRT72GxnNzF5sMK37"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Linux MM <linux-mm@kvack.org>, stable@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>


--=-BjQKRT72GxnNzF5sMK37
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-01-08 at 21:36 -0800, Shakeel Butt wrote:
> On Tue, Jan 8, 2019 at 8:01 PM Rik van Riel <riel@surriel.com> wrote:
> >=20
> > There is an imbalance between when slab_pre_alloc_hook calls
> > memcg_kmem_get_cache and when slab_post_alloc_hook calls
> > memcg_kmem_put_cache.
> >=20
>=20
> Can you explain how there is an imbalance? If the returned kmem cache
> from memcg_kmem_get_cache() is the memcg kmem cache then the refcnt
> of
> memcg is elevated and the memcg_kmem_put_cache() will correctly
> decrement the refcnt of the memcg.

Indeed, you are right. Never mind this patch.

Back to square one on that bug.

--=20
All Rights Reversed.

--=-BjQKRT72GxnNzF5sMK37
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlw2AK4ACgkQznnekoTE
3oNwFQgAobJ9soQwmXZZ20jPst6Vl7FQSysrv9t4VZcbUewwW6/5ZRB2anQinVnE
Gibkl56x1s2oZUBsrc4/Uj31f3Q4RB22cmMzHQTA2Yj2rQgcrg6bgLvFaNuQ3naN
ws1l31twrEQ8tAK7ev1J0jIrOX4zVGAc31UF+7KqQaVjm5BQB1wTlgjbJjgGOuyJ
iRuMJHC6FVyy3jEFM3QagSwx5fm5/zLgmfSecELHbfr1CLrRAZ8ZVfpxKDx8N4cw
eZ3wpjCwoaxjNWbAv4RdP8TDTyYQ539hwqQe7qhNpnd62p3V3fBKFJTv7SiPjVo/
x9W2kutLBLvyrjNoiGlSzJf0xTjj9Q==
=+tvN
-----END PGP SIGNATURE-----

--=-BjQKRT72GxnNzF5sMK37--
