Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE6D9003C7
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:15:36 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so30115514qkd.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:15:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k109si4068302qgf.32.2015.07.31.08.15.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:15:35 -0700 (PDT)
Message-ID: <55BB9110.8090306@redhat.com>
Date: Fri, 31 Jul 2015 17:15:28 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 35/36] mm: re-enable THP
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-36-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-36-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="aKwpx4aML96jbcAXRpT6sp5cskXbqTHj5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aKwpx4aML96jbcAXRpT6sp5cskXbqTHj5
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> All parts of THP with new refcounting are now in place. We can now allo=
w
> to enable THP.
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
> index c973f416cbe5..e79de2bd12cd 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -410,7 +410,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
> =20
>  config TRANSPARENT_HUGEPAGE
>  	bool "Transparent Hugepage Support"
> -	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE && BROKEN
> +	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
>  	select COMPACTION
>  	help
>  	  Transparent Hugepages allows the kernel to use huge pages and
>=20



--aKwpx4aML96jbcAXRpT6sp5cskXbqTHj5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu5ERAAoJEHTzHJCtsuoCds0H/1BxWBoiqQMf11ZQv+ZWkwCw
pqAif3ChmOwjW153faGBmNG0IxR0HZrr3hqHd4Ey/gkajpUzRRGTSWvxrG31eQmG
TKY4Z+N4NF0RWzAyQJqInc9pAhTD/2z5wfamYl665+a3Fyh/ALDqFTro7vbNqYqF
PdC0gK7Tu3ox6AK9yHVhtObUa7VpOHa89bJtK5i9QxwMkldMHyeMFGAzYbVxYV3O
6INlCtcY5ojZ4scLowDgGezo/cWVU7J4dwhZNR5IS3IPte54F4BW+LivpzXfTufv
K58kEyvP0b08bAFYEHzNj7WCiuE9THGsEDbDoI1OiUsRzHaDwNGlupOeWQfPiSM=
=kpJi
-----END PGP SIGNATURE-----

--aKwpx4aML96jbcAXRpT6sp5cskXbqTHj5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
