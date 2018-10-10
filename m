Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF8D6B0276
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:55:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id u28-v6so3627601qtu.3
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:55:36 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id l125-v6si1933296qkd.310.2018.10.09.17.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:55:34 -0700 (PDT)
Message-ID: <eb192cfdb1a3b581532a0daba22e9aaa6ad3094a.camel@surriel.com>
Subject: Re: [PATCH 1/4] mm: workingset: don't drop refault information
 prematurely fix
From: Rik van Riel <riel@surriel.com>
Date: Tue, 09 Oct 2018 20:55:28 -0400
In-Reply-To: <20181009184732.762-2-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	 <20181009184732.762-2-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ouGNk51VEckTbiQffXyq"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


--=-ouGNk51VEckTbiQffXyq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2018-10-09 at 14:47 -0400, Johannes Weiner wrote:
> The shadow shrinker is invoked per NUMA node, but the shadow limit
> enforced for cgroups is based on the page counter, which isn't NUMA
> aware. Instead of shrinking shadow pages to desired_size, we end up
> with desired_size * nr_online_nodes.
>=20
> Switch to NUMA-aware lru and slab counters to approximate cgroup
> size.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-ouGNk51VEckTbiQffXyq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlu9TgAACgkQznnekoTE
3oPiaggAspsShtaovQVpfvOwsDhbCZP54bnOk+EYcK4GMiIXDrtTuy883bbh8ptl
5QPtIxW6GgGLGm3nr6NeOH2ErhOODezvDLC8oZf4ERamRcYsxzjJKB8SYJRTxz8A
0VDRnRo2AOofQodaKOCxW6iYXUiO1QZX8NlPVGoa9WveNuo8mC2hp5k1gFMuhekY
1CTl5zpy3Opa5m+wS5SyyjIMm0iYq+ZgKkPARqeQ4wP1GCUfZj2uQ8yqqINZh4C7
FhV891Q+pzb5xggz19AX4K4rkBKzQK/Ug4bDn+vVjrC5lGzuXb2wSl4/sPDyZk0B
s16EXFprCUiSsisZHMmomfrQQ868+Q==
=51R3
-----END PGP SIGNATURE-----

--=-ouGNk51VEckTbiQffXyq--
