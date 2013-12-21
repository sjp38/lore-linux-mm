Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4884F6B0031
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 04:08:16 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so817488yhl.34
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 01:08:16 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id 41si9698487yhf.152.2013.12.21.01.08.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Dec 2013 01:08:14 -0800 (PST)
Date: Sat, 21 Dec 2013 20:04:36 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v3 01/14] mm, hugetlb: unify region structure handling
Message-ID: <20131221090436.GD15958@voom.redhat.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1387349640-8071-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C+ts3FVlLX8+P6JN"
Content-Disposition: inline
In-Reply-To: <1387349640-8071-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--C+ts3FVlLX8+P6JN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 18, 2013 at 03:53:47PM +0900, Joonsoo Kim wrote:
> Currently, to track a reserved and allocated region, we use two different
> ways for MAP_SHARED and MAP_PRIVATE. For MAP_SHARED, we use
> address_mapping's private_list and, for MAP_PRIVATE, we use a resv_map.
> Now, we are preparing to change a coarse grained lock which protect
> a region structure to fine grained lock, and this difference hinder it.
> So, before changing it, unify region structure handling.
>=20
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: David Gibson <david@gibson.dropbear.id.au>
--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--C+ts3FVlLX8+P6JN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJStVmkAAoJEGw4ysog2bOSA1wQAIncZZbCbbw2oxX879TVjs5/
kELr9xxGpMH8dOD5wGYNA0FcoEFEJpHbHHQKxX3WexsIrqxkdX9XyXl1ozJ/a+fW
gQ9VsXgLMCMbo2Y0YATGSUjUG9tMGGhPqh8unfAXr2wfQ57poTLJwJ1XoszFnAr7
D3axSN6YM6/3IHUwuDdsQe39x0Otrm+tiMkk5gdHdgLRlVS3MxL82JlGq7GsNafg
9KHCgXfxCM6hopCEz/yiNNdDX4WEm0OB8pEEyn6yTLf+Nk3GZvtVBjEwu2T4XUY3
K+Qqx3vcEC1OAOFDtN4mxbhJ9qvL8ffPYHs7EzwNeHCgx6PnoP4xjMV1ObTbmalj
4A0lnW2EWVdAbsXMAnodxKJQO2l22QrZMWB1v2YY+VXXIxWYd68oyz16tnUH/kC5
lF55KEEFY1+pZ6iJtWZtezhIVfCW+RZyMTPrjvTyW0AFsXHSVaMUHDuWh4OyRVD0
SZWhOwM63+VNxbele2icIfVHP4OI6b3W8Obxg47oA4mfAODeMfJDIxFbp/5opdsT
fNOWCyif7hy2AmFSwyDgLToovfh73LUeXRgkanHcjN/kY2+9dc23rRqChzOaAkXw
NzartPVbhM4Cv/urMtgv/tUr1Yhp6wDG8+onD55KMjU27k9iUQhH5G9GN3ZQS5yQ
29Rm9IEo/a+rAMwm3DIV
=xC18
-----END PGP SIGNATURE-----

--C+ts3FVlLX8+P6JN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
