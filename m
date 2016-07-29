Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 527736B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:55:37 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i184so109879452ywb.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:55:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a4si12753892qkf.84.2016.07.29.09.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 09:55:36 -0700 (PDT)
Message-ID: <1469811331.13905.10.camel@redhat.com>
Subject: Re: [PATCH] mm: move swap-in anonymous page into active list
From: Rik van Riel <riel@redhat.com>
Date: Fri, 29 Jul 2016 12:55:31 -0400
In-Reply-To: <1469762740-17860-1-git-send-email-minchan@kernel.org>
References: <1469762740-17860-1-git-send-email-minchan@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Dd6BkX+eYPGZC1l2JBaU"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>


--=-Dd6BkX+eYPGZC1l2JBaU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-07-29 at 12:25 +0900, Minchan Kim wrote:
> Every swap-in anonymous page starts from inactive lru list's head.
> It should be activated unconditionally when VM decide to reclaim
> because page table entry for the page always usually has marked
> accessed bit. Thus, their window size for getting a new referece
> is 2 * NR_inactive + NR_active while others is NR_active + NR_active.
>=20
> It's not fair that it has more chance to be referenced compared
> to other newly allocated page which starts from active lru list's
> head.
>=20
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

The reason newly read in swap cache pages start on the
inactive list is that we do some amount of read-around,
and do not know which pages will get used.

However, immediately activating the ones that DO get
used, like your patch does, is the right thing to do.

--=C2=A0
All Rights Reversed.
--=-Dd6BkX+eYPGZC1l2JBaU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXm4qDAAoJEM553pKExN6DCtcIAIHRnbXgRlxVfoK3rLNsXwdC
i69XPRI9Q05BWanoXj1vgKnoddrJigjBeGgksOME86EIeiuWYGcEIi8m5YSiIpHB
keJra06IoHTTTTFau7QQg2UziykSO3ax1/ORSKQZLY7hjYiGAg6nTbAnobbRYleF
xwce8RQ+WMPmyh/8RHSApAWGUTG1w17nveTo0eHACVvQIb1yErTfDAl7Cuyq0uwq
OilQvpU1ahtOP4Dk1XhhHIushxzn4JiS4WTdh/WLDraniclI1/ZnfVJzbeqwHtrJ
hfgun6XaeamYfAA1y7FCRSurlI15H0EGLSy1vBPBOlGJKmhXV2v+mWvWfzKY2co=
=mXnQ
-----END PGP SIGNATURE-----

--=-Dd6BkX+eYPGZC1l2JBaU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
