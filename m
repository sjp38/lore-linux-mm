Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1493B6B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:32:46 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 46so51264655qtr.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:32:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n184si4036182qkf.54.2016.06.06.14.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:32:45 -0700 (PDT)
Message-ID: <1465248760.16365.143.camel@redhat.com>
Subject: Re: [PATCH 02/10] mm: swap: unexport __pagevec_lru_add()
From: Rik van Riel <riel@redhat.com>
Date: Mon, 06 Jun 2016 17:32:40 -0400
In-Reply-To: <20160606194836.3624-3-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-3-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Tb7YMV/wvFM9iPKnAWsz"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com


--=-Tb7YMV/wvFM9iPKnAWsz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> There is currently no modular user of this function. We used to have
> filesystems that open-coded the page cache instantiation, but luckily
> they're all streamlined, and we don't want this to come back.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>=20
Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.


--=-Tb7YMV/wvFM9iPKnAWsz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXVev4AAoJEM553pKExN6DQBkH/jV2tC+LCmDL+Qy+d6KWFxYT
ku58eKP9snXLIFaqQfzNtn0wP/O5hc3LaWIr4T8pkbEhtOb9nFvjj2yaLNE+IdI9
JrHQvhefxA5hThY7WejvZkkrdTMJLWnJPun6hVTHUsGvO0+6UFPhwzO5wCj8zWJ+
D/neQ1EoQj5PIPNv9L78xpB4F3G6grKMFBuIZ/Narel8a43KLT8WPRgDSKgxMI+t
pMjFO+4PpPsRpXM+Tvnx5OMaHErCeuOFJPOLxvZPSY1Qqk9BEtUW58co8Bavgukt
/4r0Rvp72wHzCkIC/vEX8b0JvE5b8J5+GKkLs8p6dK8FVIOaNJW9TcHUSKSSDZs=
=P+Xv
-----END PGP SIGNATURE-----

--=-Tb7YMV/wvFM9iPKnAWsz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
