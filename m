Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9F76B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 10:11:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u142so82797689oia.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 07:11:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e5si17549353itd.85.2016.07.20.07.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 07:11:38 -0700 (PDT)
Message-ID: <1469023891.30053.69.camel@redhat.com>
Subject: Re: [PATCH v3 1/2] mm, thp: fix comment inconsistency for swapin
 readahead functions
From: Rik van Riel <riel@redhat.com>
Date: Wed, 20 Jul 2016 10:11:31 -0400
In-Reply-To: <1468109345-32258-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1468109224-29912-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1468109345-32258-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Ga9s0j3UlI7jVlbWOt4m"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, hillf.zj@alibaba-inc.com


--=-Ga9s0j3UlI7jVlbWOt4m
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-07-10 at 03:09 +0300, Ebru Akagunduz wrote:
> After fixing swapin issues, comment lines stayed as in old version.
> This patch updates the comments.
>=20
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
>=20
Acked-by: Rik van Riel <riel@redhat.com>

--=20

All Rights Reversed.
--=-Ga9s0j3UlI7jVlbWOt4m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXj4aUAAoJEM553pKExN6DdGgH/2qH0jngvTq6UusPIeOJoDqN
QtaX9U27VThrzBws3n5ow06l9R7aGY4ChzLr8kD9AFB/lbig7iFp2CaE6DFRqi87
4si4NUFnyexdfiF6UEDx+dSU0qiyKMlUDQWtsJf7AF7hk+q9uRndEciYhnBl6pam
jKrwKR8netoP1gQm2oBPJhSNj/a8/hx5DRLVi7VHxsQbDgZKLxgLG4HXPChYngMv
tiRdvDhuw3xAWs5P6RgBhhl0EpXyQy2zX64NfmardXjq4JuoFgs9tW8k0hBRYcNc
mLwXJ4bvo3Ysd4gAixxPEL3Y1wsZG/G0HrmlweNCcHJ0wyj9LsEV6Ym+vBuflT4=
=OsYK
-----END PGP SIGNATURE-----

--=-Ga9s0j3UlI7jVlbWOt4m--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
