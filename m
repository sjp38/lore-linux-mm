Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3F56B0254
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:50:29 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so29896144qkf.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:50:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f8si6010727qhc.106.2015.07.31.07.50.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:50:28 -0700 (PDT)
Message-ID: <55BB8B2C.9040909@redhat.com>
Date: Fri, 31 Jul 2015 16:50:20 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 11/36] mm: temporally mark THP broken
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-12-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="K1pNWQnmGeLjMCrVi49Bl8D935hgF6phk"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--K1pNWQnmGeLjMCrVi49Bl8D935hgF6phk
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> Up to this point we tried to keep patchset bisectable, but next patches=

> are going to change how core of THP refcounting work.
>=20
> It would be beneficial to split the change into several patches and mak=
e
> it more reviewable. Unfortunately, I don't see how we can achieve that
> while keeping THP working.
>=20
> Let's hide THP under CONFIG_BROKEN for now and bring it back when new
> refcounting get established.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e79de2bd12cd..c973f416cbe5 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -410,7 +410,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
> =20
>  config TRANSPARENT_HUGEPAGE
>  	bool "Transparent Hugepage Support"
> -	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
> +	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE && BROKEN
>  	select COMPACTION
>  	help
>  	  Transparent Hugepages allows the kernel to use huge pages and
>=20



--K1pNWQnmGeLjMCrVi49Bl8D935hgF6phk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4ssAAoJEHTzHJCtsuoCZdAH/0JpJRIM3/b9D6QBRujMwT7W
gEDMmkr/AhI8gfERZG3RLMTzT+U1KVQsaIW/sNLT87RayR1ZTk8AcEnbn4z7xhnJ
yRwJoKk7nonVjZPEE6HRp8i7/OPOCeeTTT7X+U+Meav1BaNFPHLs+X7VKZ/dr6/k
M6e3aeO0EKJ9qBRwTVclO39UuWJTv1R1mQR0L0acHw5c2nUfO5XxKloq+xhkPqRH
YRmVNaXElxDL3Of4+58fCkVTNSCXrudYDiFB3bAdiHxaVsZvfv6TZM1DF9mwEk9z
0LrbcIfWVAwg9TfnzNbtlMC8UOAwr8eLhLJ1VLiNYBJQk+V6KJLJK00agfJ2yg0=
=JaR9
-----END PGP SIGNATURE-----

--K1pNWQnmGeLjMCrVi49Bl8D935hgF6phk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
