Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE8916B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 11:41:25 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e88-v6so14363076qtb.1
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:41:25 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id t16-v6si3823951qvk.221.2018.10.01.08.41.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 08:41:25 -0700 (PDT)
Message-ID: <211a65a21d69ed8d358f3638d02c3f6ee63d3426.camel@surriel.com>
Subject: Re: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker
 early in the lifetime of a task
From: Rik van Riel <riel@surriel.com>
Date: Mon, 01 Oct 2018 11:41:24 -0400
In-Reply-To: <20181001100525.29789-3-mgorman@techsingularity.net>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
	 <20181001100525.29789-3-mgorman@techsingularity.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-bPx8Hj1pWOxURgOTygS/"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Jirka Hladky <jhladky@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>


--=-bPx8Hj1pWOxURgOTygS/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2018-10-01 at 11:05 +0100, Mel Gorman wrote:
> With this patch applied, STREAM performance is the same as 4.17 even
> though
> processes are not spread cross-node prematurely. Other workloads
> showed
> a mix of minor gains and losses. This is somewhat expected most
> workloads
> are not very sensitive to the starting conditions of a process.
>=20
>                          4.19.0-rc5             4.19.0-
> rc5                 4.17.0
>                          numab-v1r1       fastmigrate-
> v1r1                vanilla
> MB/sec copy     43298.52 (   0.00%)    47335.46
> (   9.32%)    47219.24 (   9.06%)
> MB/sec scale    30115.06 (   0.00%)    32568.12
> (   8.15%)    32527.56 (   8.01%)
> MB/sec add      32825.12 (   0.00%)    36078.94
> (   9.91%)    35928.02 (   9.45%)
> MB/sec triad    32549.52 (   0.00%)    35935.94
> (  10.40%)    35969.88 (  10.51%)
>=20
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Reviewed-by: Rik van Riel <riel@surriel.com>
--=20
All Rights Reversed.

--=-bPx8Hj1pWOxURgOTygS/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAluyQCQACgkQznnekoTE
3oOjhggAhKHjjlZ5+V2k2HFgnNIwP0BIaJIGI1w/SNNWSoK5lA33XfRVtj1u64Un
f4Vv8MS7uc/zThlSck2OOnXN29+oDv9xsYdjqk+8EpWELMcaMnmkgBKke82ftMaO
Y+kozORrA7iBMmghlnULz4cmg5VGNEWcGyewakvY9arezLd1GjIWPpbTnR4dZogw
QFyOjzRkLdsIdXo/gA5WFv6G98M3vTO6Bv14wbvEsQ1HVq3COJGCJgoXcAepIvxa
BUrwOG4OnjWwJFO+RjgyZW4imK59IZAdEBXiCCJLpyBzCHdn3nvAgHH8ph9hq82g
GtxME+JN5Z37IapgSQY7DOv5QumKCg==
=4kM/
-----END PGP SIGNATURE-----

--=-bPx8Hj1pWOxURgOTygS/--
