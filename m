Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D62916B0038
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 09:52:42 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i184so40869929itf.3
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 06:52:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y132si5130084itf.9.2016.09.02.06.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 06:52:42 -0700 (PDT)
Message-ID: <1472824355.32433.135.camel@redhat.com>
Subject: Re: [PATCH] mm, thp: fix leaking mapped pte in
 __collapse_huge_page_swapin()
From: Rik van Riel <riel@redhat.com>
Date: Fri, 02 Sep 2016 09:52:35 -0400
In-Reply-To: <1472820276-7831-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1472820276-7831-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-9RCdTANypk+wOtUruJmz"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org


--=-9RCdTANypk+wOtUruJmz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-09-02 at 15:44 +0300, Ebru Akagunduz wrote:
> Currently, khugepaged does not let swapin, if there is no
> enough young pages in a THP. The problem is when a THP does
> not have enough young page, khugepaged leaks mapped ptes.
>=20
> This patch prohibits leaking mapped ptes.
>=20
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
>=20
Reviewed-by: Rik van Riel <riel@redhat.com>

--=20

All Rights Reversed.
--=-9RCdTANypk+wOtUruJmz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXyYQkAAoJEM553pKExN6DUCEIAJDkldhHnze8Wkb/WsGfvGML
rqKsx9u919DH18W7lZxfphrCw3OsO1nYUPjOsB7WFk6HHZsIHJPStKtodr/fplZj
PzN0/cUkbtZQTcGqQ4Q6K//AzpvC5s3t2qUbE6Yj0HkY4jBwUgHvg66KTjOQ+BYN
q9t6wodu3exxBQkGaGk4mbGBeVIHX4/R/lVer2sgKm3U9722iC9oDvQ7xg6kgD60
oTU0nTSseDeAEgH5OEZhSTu8L/yvhdZTcEcVM+nyRNXmfQmBQXEOIwwbNIu/1ZsD
fQNZjDLxUVWGo6R4otYWNtDhcsz5uDvUrkpUybcRy1TfP398BtHIDS8JbVsX9vI=
=du7i
-----END PGP SIGNATURE-----

--=-9RCdTANypk+wOtUruJmz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
