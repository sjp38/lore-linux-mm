Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C23636B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 13:47:41 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v76so9903433qka.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 10:47:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e64si11619472qkd.460.2017.07.25.10.47.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 10:47:41 -0700 (PDT)
Message-ID: <1501004857.26846.19.camel@redhat.com>
Subject: Re: [PATCH -mm -v3 02/12] mm, THP, swap: Support to reclaim swap
 space for THP swapped out
From: Rik van Riel <riel@redhat.com>
Date: Tue, 25 Jul 2017 13:47:37 -0400
In-Reply-To: <20170724051840.2309-3-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
	 <20170724051840.2309-3-ying.huang@intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-o2eE1NAoZv70K1qCkVmO"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>


--=-o2eE1NAoZv70K1qCkVmO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-07-24 at 13:18 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
>=20
> The normal swap slot reclaiming can be done when the swap count
> reaches SWAP_HAS_CACHE.=C2=A0=C2=A0But for the swap slot which is backing=
 a
> THP,
> all swap slots backing one THP must be reclaimed together, because
> the
> swap slot may be used again when the THP is swapped out again later.
> So the swap slots backing one THP can be reclaimed together when the
> swap count for all swap slots for the THP reached SWAP_HAS_CACHE.=C2=A0=
=C2=A0In
> the patch, the functions to check whether the swap count for all swap
> slots backing one THP reached SWAP_HAS_CACHE are implemented and used
> when checking whether a swap slot can be reclaimed.
>=20
> To make it easier to determine whether a swap slot is backing a THP,
> a
> new swap cluster flag named CLUSTER_FLAG_HUGE is added to mark a swap
> cluster which is backing a THP (Transparent Huge Page).=C2=A0=C2=A0Becaus=
e THP
> swap in as a whole isn't supported now.=C2=A0=C2=A0After deleting the THP=
 from
> the swap cache (for example, swapping out finished), the
> CLUSTER_FLAG_HUGE flag will be cleared.=C2=A0=C2=A0So that, the normal pa=
ges
> inside THP can be swapped in individually.
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
--=-o2eE1NAoZv70K1qCkVmO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZd4Q5AAoJEM553pKExN6DrRcIAKvnKL8laMQ9MPFPw3EoDeta
f5egjp11AMxck1NOJ0nq/j/1hWjQjvsjwnaubqPdfuyUv71N4aSV9Jb+YahSZv82
xeQV5lvVI1+7mqMLEsEovDMIJ9bq9ToW+d7xglIMUuGrMI20xsxfz/YPEmB6XOpZ
KD77B/1USBab3WLVjbcSr38xUcAbHCHvZ9H40ZGc/3js891BY5V/2e8/TSZIWw+M
adNjK0CrrqB7HezTBuycImklBwg31YH2zMGWA5sTE27qoQhu1QZ/l/NBXbwNl80V
5CN1pAZ6B5fyHV2DZZ5UtUcz/dkBx1fkMPbbWSPfd72ahwBFmh+UV32J7r1Htyc=
=0QHb
-----END PGP SIGNATURE-----

--=-o2eE1NAoZv70K1qCkVmO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
