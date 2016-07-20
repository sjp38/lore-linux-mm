Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D61E6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 10:14:19 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u142so82898163oia.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 07:14:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g72si17652886itg.53.2016.07.20.07.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 07:14:18 -0700 (PDT)
Message-ID: <1469024054.30053.70.camel@redhat.com>
Subject: Re: [RFC PATCH v3 2/2] mm, thp: convert from optimistic swapin
 collapsing to conservative
From: Rik van Riel <riel@redhat.com>
Date: Wed, 20 Jul 2016 10:14:14 -0400
In-Reply-To: <1468109451-1615-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1468109224-29912-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1468109451-1615-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-FH0g54KZlRchV+LwO9L5"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com


--=-FH0g54KZlRchV+LwO9L5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-07-10 at 03:10 +0300, Ebru Akagunduz wrote:
> To detect whether khugepaged swapin worthwhile, this patch checks
> the amount of young pages. There should be at least half of
> HPAGE_PMD_NR to swapin.
>=20
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Suggested-by: Minchan Kim <minchan@kernel.org>
>=20
Acked-by: Rik van Riel <riel@redhat.com>

--=20

All Rights Reversed.
--=-FH0g54KZlRchV+LwO9L5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXj4c2AAoJEM553pKExN6DVx0IAJyoOc7CsMPv17u/p+oiP1+V
T7vIlm26TZIJjDFiyHQSgjOdPX1HBAkegiNOfzO116+JgbOQqF3nMzg1VYM4p/Qz
Zsspzz/SA5HVT1dpU/Bwrk078n/eguJezN9b7elFpN4+39KZ3so/kXqdL+ygja2V
oTLXJHHo7cZPoDKPlt0nqYDGol9lXfBEr2eAN91ZvewiR+DZIif4aAI5bWl3w8QQ
CtumVRohxCL4wyuds1BNh8H1KuZIqc4/IFN2i1++o83eq+odSc9uPfQASycBMnrQ
ww2P+MlQ25KLgoRnoycXQJstLDBEixdJ/rDBgTwS4V+6BhGKRMrHaSIMU2tFkFA=
=Qtqg
-----END PGP SIGNATURE-----

--=-FH0g54KZlRchV+LwO9L5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
