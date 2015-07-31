Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0129E6B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:06:08 -0400 (EDT)
Received: by qgii95 with SMTP id i95so47477087qgi.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:06:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 141si6112378qhg.26.2015.07.31.08.06.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:06:07 -0700 (PDT)
Message-ID: <55BB8ED8.7090803@redhat.com>
Date: Fri, 31 Jul 2015 17:06:00 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 28/36] mm, numa: skip PTE-mapped THP on numa fault
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-29-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="AXweow82f5MAWuNrXSD9tdLGEwQm0wnHO"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AXweow82f5MAWuNrXSD9tdLGEwQm0wnHO
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> We're going to have THP mapped with PTEs. It will confuse numabalancing=
=2E
> Let's skip them for now.

Fair enough.

Acked-by: Jerome Marchand <jmarchan@redhat.com>

>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/memory.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index 074edab89b52..52f6fa02c099 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3186,6 +3186,12 @@ static int do_numa_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
>  		return 0;
>  	}
> =20
> +	/* TODO: handle PTE-mapped THP */
> +	if (PageCompound(page)) {
> +		pte_unmap_unlock(ptep, ptl);
> +		return 0;
> +	}
> +
>  	/*
>  	 * Avoid grouping on RO pages in general. RO pages shouldn't hurt as
>  	 * much anyway since they can be in shared cache state. This misses
>=20



--AXweow82f5MAWuNrXSD9tdLGEwQm0wnHO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu47YAAoJEHTzHJCtsuoCbasIAJgqsduVoqeOUNlUaQ1WP+tp
HirYtRMig2zvYlx3TPq9M5xribvKtTKRMvsyhSZb3t6u1y5lCbCgr+K+cBtMTL5Z
KF744MQuVxRpL8FDfTbwT+eYW/4uLIemMx8Fao0fGZibB7j7rZeB/aKy9dC3t0+V
tYw6OHkeiVoSrrMLxe1B9VLWBI01iHFRcy4CcqxuTHlkW15RgKfm6GY/5dUf0wj3
js764sshaBdYBbYmZpzadji3362kpGFtDy/BMib+WtEN/kgISEb1a/WLKKHhRjTX
KfyRfa8yQ4yl3hGsiOG3u2ylVW+uiWy/SdlBp3RUAtLXn2uHcPHeJ2VsVFXAZR8=
=0iGW
-----END PGP SIGNATURE-----

--AXweow82f5MAWuNrXSD9tdLGEwQm0wnHO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
