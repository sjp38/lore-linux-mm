Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9A986B007E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:33:50 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id x189so431357770ywe.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:33:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s67si13238610qhe.87.2016.06.06.14.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:33:50 -0700 (PDT)
Message-ID: <1465248826.16365.144.camel@redhat.com>
Subject: Re: [PATCH 03/10] mm: fold and remove lru_cache_add_anon() and
 lru_cache_add_file()
From: Rik van Riel <riel@redhat.com>
Date: Mon, 06 Jun 2016 17:33:46 -0400
In-Reply-To: <20160606194836.3624-4-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-4-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-EM/Q4cHA9vYMJfjzGrhM"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com


--=-EM/Q4cHA9vYMJfjzGrhM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> They're the same function, and for the purpose of all callers they
> are
> equivalent to lru_cache_add().
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>=20
Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.


--=-EM/Q4cHA9vYMJfjzGrhM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXVew6AAoJEM553pKExN6DOMAH/3dW/bzfQ3pTA3f97Z8YvULN
Hkz6BGSk7bgSsc+MjKvKhVEfQfoj0UL7G3F1+pDQP06gIocW6z9+LotVcI+vcFfb
McOfmMuMT4VJW5p4IRYxagCBT5wD6JAWNLIBkkWz0LUFNvxk4q7xw6+J/l6HGDni
hObGKNPtT2vDXXNEoeAlMAgoUlR9bVYaIVxbnnYuyJPYQdb4nnqE74SWwgcHFf3v
8iIxZptDbALd2hYJVUIchh/XCwtTJZ5/UGjQLYxc/UDqyT8E7vZelnDPY0ZEy54/
hjvnu55x1ASkpxoR+PenL/7SuJRJ/oMKVR1msi7M332QK4LGh3JkGFHTWaKKfbM=
=UE9T
-----END PGP SIGNATURE-----

--=-EM/Q4cHA9vYMJfjzGrhM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
