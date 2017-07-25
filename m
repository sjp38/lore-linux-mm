Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 124DB6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:39:19 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u11so11348803qtu.10
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 09:39:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 50si11052629qto.356.2017.07.25.09.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 09:39:18 -0700 (PDT)
Message-ID: <1501000754.26846.18.camel@redhat.com>
Subject: Re: [PATCH -mm -v3 01/12] mm, THP, swap: Support to clear swap
 cache flag for THP swapped out
From: Rik van Riel <riel@redhat.com>
Date: Tue, 25 Jul 2017 12:39:14 -0400
In-Reply-To: <20170724051840.2309-2-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
	 <20170724051840.2309-2-ying.huang@intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-JGnX+WNAlkTa98wxgIIV"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>


--=-JGnX+WNAlkTa98wxgIIV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-07-24 at 13:18 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
>=20
> Previously, swapcache_free_cluster() is used only in the error path
> of
> shrink_page_list() to free the swap cluster just allocated if the
> THP (Transparent Huge Page) is failed to be split.=C2=A0=C2=A0In this pat=
ch, it
> is enhanced to clear the swap cache flag (SWAP_HAS_CACHE) for the
> swap
> cluster that holds the contents of THP swapped out.
>=20
> This will be used in delaying splitting THP after swapping out
> support.=C2=A0=C2=A0Because there is no THP swapping in as a whole suppor=
t yet,
> after clearing the swap cache flag, the swap cluster backing the THP
> swapped out will be split.=C2=A0=C2=A0So that the swap slots in the swap
> cluster
> can be swapped in as normal pages later.
>=20
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
>=20

Acked-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-JGnX+WNAlkTa98wxgIIV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZd3QyAAoJEM553pKExN6DIBIH+QGfbnm2XcCh4zLIhdcxewg9
M+keFO2JB5XGcCMkVJN80nQeI0clW6i+QcfCDWTKnVbgfmJL9Vyxe7UyvuDWDX3k
kNgocM9neGx823Q43h1xN0UoxUsZVreSXAMzAq8iGfGaJR96gYeWn+oHJ+2hK3AM
xe/gtX4GWtj2sVnres2VD0tMB2BypNFjMUO6NdyCaYyxD5gFSgqU4zCW1bztxcEF
2PdXXU6TfRd549SnZYXKP/JMXyzCwaJlwkFTQc7zUd1Kb81S8wpuxDJQ9sU/4+Zj
8g6urYb6SDWTSVcZvklDfRPihE47sp1sEh6HS51U8mUj/UvxMMZ/dk9gJDwSkMY=
=+Exg
-----END PGP SIGNATURE-----

--=-JGnX+WNAlkTa98wxgIIV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
