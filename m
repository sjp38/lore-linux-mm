Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56B756B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:36:14 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id f5so169558265vkb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:36:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n72si12167085qkn.142.2016.06.06.14.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:36:13 -0700 (PDT)
Message-ID: <1465248969.16365.145.camel@redhat.com>
Subject: Re: [PATCH 04/10] mm: fix LRU balancing effect of new transparent
 huge pages
From: Rik van Riel <riel@redhat.com>
Date: Mon, 06 Jun 2016 17:36:09 -0400
In-Reply-To: <20160606194836.3624-5-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-5-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-bQ15HzmXtwY2/GN+hWTB"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com


--=-bQ15HzmXtwY2/GN+hWTB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> Currently, THP are counted as single pages until they are split right
> before being swapped out. However, at that point the VM is already in
> the middle of reclaim, and adjusting the LRU balance then is useless.
>=20
> Always account THP by the number of basepages, and remove the fixup
> from the splitting path.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>=20

Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.


--=-bQ15HzmXtwY2/GN+hWTB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXVezKAAoJEM553pKExN6Db2wIAIXJn/KfQgRlr8CueBROD0G8
cM56g6LqZVVTBWLPwCjMyl0PsGnnOwNW1/AhYvgB7PFLY0eTOOesY8gjEKV6Aort
FXdttaGlPkAA2do0fEu5Co1NKRkFX5fECPNHSlnKqZnngqehbPMRTRQPHj/yJSQh
zVS4+WDsyVKk6GwWzSYQMRTKRw2CVNL3ttUp1lPGBbTxixau1N9IkvSkaI2Tm5bt
869GLYRav04Ju39CzGXy4hJ7Yvppyl/w5RgwYUAz84iWyA+3NLIu2EXSEUG6N9C2
AYh6cjJTJ1+S3idgoLHY37v1b37HFjvDP7fJ/leLdfgjxnnCy0I7FCJ2D2Ix2VA=
=SpWG
-----END PGP SIGNATURE-----

--=-bQ15HzmXtwY2/GN+hWTB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
