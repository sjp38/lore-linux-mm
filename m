Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44E106B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 21:11:24 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id f5so178926620vkb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 18:11:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t27si657868qtt.21.2016.06.06.18.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 18:11:23 -0700 (PDT)
Message-ID: <1465261878.16365.149.camel@redhat.com>
Subject: Re: [PATCH 05/10] mm: remove LRU balancing effect of temporary page
 isolation
From: Rik van Riel <riel@redhat.com>
Date: Mon, 06 Jun 2016 21:11:18 -0400
In-Reply-To: <20160606221550.GA6665@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-6-hannes@cmpxchg.org>
	 <1465250169.16365.147.camel@redhat.com> <20160606221550.GA6665@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-DEsm4J3ppzrMGOLVNmll"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com


--=-DEsm4J3ppzrMGOLVNmll
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-06 at 18:15 -0400, Johannes Weiner wrote:
> On Mon, Jun 06, 2016 at 05:56:09PM -0400, Rik van Riel wrote:
> >=20
> > On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> > >=20
> > > =C2=A0
> > > +void lru_cache_putback(struct page *page)
> > > +{
> > > +	struct pagevec *pvec =3D &get_cpu_var(lru_putback_pvec);
> > > +
> > > +	get_page(page);
> > > +	if (!pagevec_space(pvec))
> > > +		__pagevec_lru_add(pvec, false);
> > > +	pagevec_add(pvec, page);
> > > +	put_cpu_var(lru_putback_pvec);
> > > +}
> > >=20
> > Wait a moment.
> >=20
> > So now we have a putback_lru_page, which does adjust
> > the statistics, and an lru_cache_putback which does
> > not?
> >=20
> > This function could use a name that is not as similar
> > to its counterpart :)
> lru_cache_add() and lru_cache_putback() are the two sibling
> functions,
> where the first influences the LRU balance and the second one
> doesn't.
>=20
> The last hunk in the patch (obscured by showing the label instead of
> the function name as context) updates putback_lru_page() from using
> lru_cache_add() to using lru_cache_putback().
>=20
> Does that make sense?

That means the page reclaim does not update the
"rotated" statistics.  That seems undesirable,
no?  Am I overlooking something?


--=20
All Rights Reversed.


--=-DEsm4J3ppzrMGOLVNmll
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXVh82AAoJEM553pKExN6DCCMIAI7IV8X195ET31hixsf9c4pW
I7xGVhc4UAyZYAn5wnPGZqU2Gi8wnuv0Z+JTOYNRKL88cNR4EzNQynotdxqVsQXd
Hn82qO3QQ1ylyB9RugZVyVYKJDOhKhxVRXjTSo66gNK5DzURQtvQUcNZjIzqYLHK
VeCfr4YGMMXKN6/A66ESqvhkISKQ9LW8ZYTr/6L8Upwt873U+RNmvDwd1M+DkQEa
c5iBQReJeJBarwcBcAfjhtqmWAn0C+TLcL9m4e2FvpGllIMMIXOzreIEsG7g1Ung
w7rI5A/mHiHYBP+Pm6lHZdtdJho9m20KC1Bos3snYyFpQFMJxYbPVCVfiAp47Dw=
=G57z
-----END PGP SIGNATURE-----

--=-DEsm4J3ppzrMGOLVNmll--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
