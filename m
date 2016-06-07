Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC966B007E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 22:20:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i187so261415697qkd.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 19:20:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f94si13855007qtb.114.2016.06.06.19.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 19:20:36 -0700 (PDT)
Message-ID: <1465266031.16365.153.camel@redhat.com>
Subject: Re: [PATCH 06/10] mm: remove unnecessary use-once cache bias from
 LRU balancing
From: Rik van Riel <riel@redhat.com>
Date: Mon, 06 Jun 2016 22:20:31 -0400
In-Reply-To: <20160606194836.3624-7-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-7-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Hh3bOxqBqTybgtTa1zTW"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com


--=-Hh3bOxqBqTybgtTa1zTW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> When the splitlru patches divided page cache and swap-backed pages
> into separate LRU lists, the pressure balance between the lists was
> biased to account for the fact that streaming IO can cause memory
> pressure with a flood of pages that are used only once. New page
> cache
> additions would tip the balance toward the file LRU, and repeat
> access
> would neutralize that bias again. This ensured that page reclaim
> would
> always go for used-once cache first.
>=20
> Since e9868505987a ("mm,vmscan: only evict file pages when we have
> plenty"), page reclaim generally skips over swap-backed memory
> entirely as long as there is used-once cache present, and will apply
> the LRU balancing when only repeatedly accessed cache pages are left
> -
> at which point the previous use-once bias will have been neutralized.
>=20
> This makes the use-once cache balancing bias unnecessary. Remove it.
>=20

The code in get_scan_count() still seems to use the statistics
of which you just removed the updating.

What am I overlooking?

--=20
All Rights Reversed.


--=-Hh3bOxqBqTybgtTa1zTW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXVi9wAAoJEM553pKExN6DK8MIALmRQa8GKIDg16qI26UguPKp
KZlqTGGlTwLCX7EIf/HKx0xszSzmFGyM+s1kAQ+Gr+UqQHU+hbboQJraLJ73JNJk
AYCXqzZn9GJ50gWCRbup/Bq1C9KVtRWv2ZEdbAkTKLnaoJqMs2x8Zq2jmP2ozzQv
hiQMpCOuHqg/AVV1gJrrXcdKDApOZUrrzHqrJW7MayCwbv4797VqZj9b0EYwJx2w
G63CnaTThpELN/2HzB+prWRntRlrnxxTQ4qr+EGDeViUc8LlihYJFTl2chcCbNmn
ynWxSPs+yt4u1fq3g+7EGnWvHeGBif5XazREPZkxePtRg+VCE0GxWcQ5PrxxSAs=
=svIi
-----END PGP SIGNATURE-----

--=-Hh3bOxqBqTybgtTa1zTW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
