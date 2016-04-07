Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id DD0256B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 13:34:52 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id c6so69376907qga.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 10:34:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e13si6662882qka.120.2016.04.07.10.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 10:34:52 -0700 (PDT)
Message-ID: <1460050486.30063.4.camel@redhat.com>
Subject: Re: [PATCH v5 2/2] mm, thp: avoid unnecessary swapin in khugepaged
From: Rik van Riel <riel@redhat.com>
Date: Thu, 07 Apr 2016 13:34:46 -0400
In-Reply-To: <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-vS9H0Bw3ChcPJo1DNHm/"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com


--=-vS9H0Bw3ChcPJo1DNHm/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-07 at 20:28 +0300, Ebru Akagunduz wrote:
> Currently khugepaged makes swapin readahead to improve
> THP collapse rate. This patch checks vm statistics
> to avoid workload of swapin, if unnecessary. So that
> when system under pressure, khugepaged won't consume
> resources to swapin and won't trigger direct reclaim
> when swapin readahead.
>=20
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. The system
> was forced to swap out all. Afterwards, the test program
> touches the area by writing, it skips a page in each
> 20 pages of the area. When waiting to swapin readahead
> left part of the test, the memory forced to be busy
> doing page reclaim. There was enough free memory during
> test, khugepaged did not swapin readahead due to business.
>=20
> Test results:
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Aft=
er swapped out
> -------------------------------------------------------------------
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0| Anonymous | AnonHugePages | Swap=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0| Fraction=C2=A0=C2=A0|
> -------------------------------------------------------------------
> With patch=C2=A0=C2=A0=C2=A0=C2=A0| 0 kB=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0|=C2=A0=C2=A00 kB=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=
 800000 kB |=C2=A0=C2=A0=C2=A0=C2=A0%100=C2=A0=C2=A0=C2=A0|
> -------------------------------------------------------------------
> Without patch | 0 kB=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A00 kB=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 800000 kB |=C2=A0=
=C2=A0=C2=A0=C2=A0%100=C2=A0=C2=A0=C2=A0|
> -------------------------------------------------------------------
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Aft=
er swapped in
> -------------------------------------------------------------------
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0| Anonymous | AnonHugePages | Swap=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0| Fraction=C2=A0=C2=A0|
> -------------------------------------------------------------------
> With patch=C2=A0=C2=A0=C2=A0=C2=A0| 384812 kB | 96256 kB=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0| 415188 kB |=C2=A0=C2=A0=C2=A0=C2=A0%25=C2=A0=C2=A0=
=C2=A0=C2=A0|
> -------------------------------------------------------------------
> Without patch | 389728 kB | 194560 kB=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 4102=
72 kB |=C2=A0=C2=A0=C2=A0=C2=A0%49=C2=A0=C2=A0=C2=A0=C2=A0|
> -------------------------------------------------------------------
>=20
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.


--=-vS9H0Bw3ChcPJo1DNHm/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXBpo2AAoJEM553pKExN6Dha8H/RCHMF/uBvVvgXPqX61mPCZD
pCf4C+fTL1CPdgBOP35E74w/Fs4NKHXcbMZG1j0xoM1qGW/Z5W1UQ4J7poO8icyh
cXbcfrGM1j0Z2kfGp7xM9AuOhv8A4L1PndsJ4OV47NwV5QrkbLuZpe/e3GRJhbam
Wa0shd1+EbIdWpMrpDcEdtGvu1dg9Nnr6tYTHI/3/B3iEDOtqq+Rx26GGznohNGk
DMAtA/CPykEqjiPPQvfD6UJeTsJA6hxfzw/T99e/SV4GL8LgxTAt2W+GqTA3rXSI
cet6+Uz1hCeWCpTBeSstsTllx/s9Fs3OmXKebfDI/J1owbLXZtWWcJI01EGV8RI=
=PB2K
-----END PGP SIGNATURE-----

--=-vS9H0Bw3ChcPJo1DNHm/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
