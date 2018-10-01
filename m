Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B88A6B000C
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 11:39:45 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id a26-v6so9067058qtb.22
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:39:45 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id d1-v6si40954qtl.321.2018.10.01.08.39.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 08:39:43 -0700 (PDT)
Message-ID: <a43fc0dcf83c077b1df08ba0e9aaa9c9bf65d5a3.camel@surriel.com>
Subject: Re: [PATCH 1/2] mm, numa: Remove rate-limiting of automatic numa
 balancing migration
From: Rik van Riel <riel@surriel.com>
Date: Mon, 01 Oct 2018 11:39:38 -0400
In-Reply-To: <20181001100525.29789-2-mgorman@techsingularity.net>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
	 <20181001100525.29789-2-mgorman@techsingularity.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-b8SOSbGpPkVSzD2HHy3s"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Jirka Hladky <jhladky@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>


--=-b8SOSbGpPkVSzD2HHy3s
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2018-10-01 at 11:05 +0100, Mel Gorman wrote:
>=20
> STREAM on 2-socket machine
>                          4.19.0-rc5             4.19.0-rc5
>                          numab-v1r1       noratelimit-v1r1
> MB/sec copy     43298.52 (   0.00%)    44673.38 (   3.18%)
> MB/sec scale    30115.06 (   0.00%)    31293.06 (   3.91%)
> MB/sec add      32825.12 (   0.00%)    34883.62 (   6.27%)
> MB/sec triad    32549.52 (   0.00%)    34906.60 (   7.24%
>=20
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Reviewed-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-b8SOSbGpPkVSzD2HHy3s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAluyP7oACgkQznnekoTE
3oOQvwgAl8N5coXoRiC8EPbZWHxKYiA95wq1lkYJ0lE18HgqQ70Oq3j84qPjN503
v5tb8xHk0+BJxwTQzWRWo/9MLhHlBwIgoJHKS+k9kCm7KJxps/ntExCC0FDbmRs+
4rrfj/ReNyyJjZEfNeapZKgWf33MXIoO/DXr6a7+GWeAOHkanyzlGxAqDMalelk+
8OdgviZ2Ib7aNOS/gyrJ2WBmiVrcPJhikMzC+X4iaKSt6ZAYdrlSvKyHPHUyqUSM
DhomgmtpUKDqjbRhXYqPlztYERITI1EwtHdrzZpFQaTA9/r+3khxE+I6un4mPsZp
/5xh5t3mt28fBawHL7fgeHuxUsM1vQ==
=OgZv
-----END PGP SIGNATURE-----

--=-b8SOSbGpPkVSzD2HHy3s--
