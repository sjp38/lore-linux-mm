Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD8B76B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:56:14 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c127so432073204ywb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:56:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t93si13309141qtd.107.2016.06.06.14.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:56:14 -0700 (PDT)
Message-ID: <1465250169.16365.147.camel@redhat.com>
Subject: Re: [PATCH 05/10] mm: remove LRU balancing effect of temporary page
 isolation
From: Rik van Riel <riel@redhat.com>
Date: Mon, 06 Jun 2016 17:56:09 -0400
In-Reply-To: <20160606194836.3624-6-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-6-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-bredFTChnbwOcH2Y7WNE"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com


--=-bredFTChnbwOcH2Y7WNE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
>=C2=A0
> +void lru_cache_putback(struct page *page)
> +{
> +	struct pagevec *pvec =3D &get_cpu_var(lru_putback_pvec);
> +
> +	get_page(page);
> +	if (!pagevec_space(pvec))
> +		__pagevec_lru_add(pvec, false);
> +	pagevec_add(pvec, page);
> +	put_cpu_var(lru_putback_pvec);
> +}
>=20

Wait a moment.

So now we have a putback_lru_page, which does adjust
the statistics, and an lru_cache_putback which does
not?

This function could use a name that is not as similar
to its counterpart :)

--=20
All Rights Reversed.


--=-bredFTChnbwOcH2Y7WNE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXVfF5AAoJEM553pKExN6Do44IAKu9d5DmLKiufZ7Yg4B19W53
5cFG2C/Ny9RxtJ8wQy/RRMqN+ykluUH8uMC6q3BQ3XkluWPYR9/gY7bhdnH7xgM0
hfDgFfrpn1RuRtZYCbQL0E7UcJ7VO1oR7TJusrktLoKPi3y5IDvSZG8kkaGsKHFC
7VaHiAsOmcJYi7jTMmTV310w0QGnEbyRgm7Cc6Muf+K05uCH3kET2ZLCX8lZlBSr
HIJtuwnY82NTniVdIewH42l7cm0KAoS3x+OzGW1DkTpgk0Y1qmh9IG9RHgCJzqFO
Gn1hGWiCqLemzqGWoY5TylH1CEqTq1ekVa+Xv0AkPrmXnL8pxoB/tacAcCPtfgo=
=dbpz
-----END PGP SIGNATURE-----

--=-bredFTChnbwOcH2Y7WNE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
