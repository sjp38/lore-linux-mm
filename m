Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1F30C6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 21:00:36 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id 6so811493bkj.27
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 18:00:35 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id ew1si7492643wjd.18.2014.03.06.18.00.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 18:00:34 -0800 (PST)
Message-ID: <1394157629.2861.42.camel@deadeye.wl.decadent.org.uk>
Subject: [PATCH] mm: Fix URL for zsmalloc benchmark
From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 07 Mar 2014 02:00:29 +0000
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QMH7tXFWA0ByngzREER5"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org


--=-QMH7tXFWA0ByngzREER5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The help text for CONFIG_PGTABLE_MAPPING has an incorrect URL.
While we're at it, remove the unnecessary footnote notation.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 mm/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 2d9f150..2888024 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -575,5 +575,5 @@ config PGTABLE_MAPPING
 	  then you should select this. This causes zsmalloc to use page table
 	  mapping rather than copying for object mapping.
=20
-	  You can check speed with zsmalloc benchmark[1].
-	  [1] https://github.com/spartacus06/zsmalloc
+	  You can check speed with zsmalloc benchmark:
+	  https://github.com/spartacus06/zsmapbench

--=20
Ben Hutchings
Unix is many things to many people,
but it's never been everything to anybody.

--=-QMH7tXFWA0ByngzREER5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxkoPee/yOyVhhEJAQof5hAAs2McdBojlz8x1m2F0SqLy0SJBpLoKSwn
yPNUdDKLWTBPz6NwNsxcnqeEh08MlAYofyb3mUS/SL28fQq7qgk4xAnNSQSYn8vk
LMvi7z9sv85Vm/3yXNG6pySokX012D1i6bALLtA+Nzp6AJ7zyhw61bSanUWxXU1x
qDdC/KyRJC0oxgTrZpLbfnJa0GExTemS+JdW7OcRcfU6dp04MXdODkz+siihUNHk
o6SyIt+NekYQaeV8I6r35+Hk1WHf9Mtm//eXgpSyeCm9mwkhj2W69UQHrRoOoDRO
sxhzpcIpXdkRivSl+2APsPMOvP76stpxcCyGhrYngzqa9BuS3QxxZlWz94GVtfg3
yuULL+J8LHxxD1pSNC639cmGiOdJ4rkCtS72rZVJ/qmCQWgjO8zQsoB9Ah2usrVW
vhfnuCAgNKC0Cn9GT9dhMC9CoAdMmMpSjxRm/NxGjxDdtqosri36GtpkAe0T0ZaZ
SQAkcAsDGZz8EEEcFq8nsixVGk9DxZcI6pMppsr+PKeEKvyJ7L1+HmaK8CCOMc+/
W42OmNNd3Bl9IexcbLg5+htb0AfAVJnPIET7r0gJB+ajJx7whYE5jb7q6wiQwqDY
logHM+ZY9f+AGicJiFEPaW6ZcwRSEZ7KpJXkuB4BLvoFdBCZ8Ce7r5zhzk4RE1JQ
ldexdby0+WM=
=J/y6
-----END PGP SIGNATURE-----

--=-QMH7tXFWA0ByngzREER5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
