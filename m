Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 541426B0255
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:05:05 -0400 (EDT)
Received: by ykax123 with SMTP id x123so61422598yka.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:05:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b92si6124513qkh.30.2015.07.31.08.05.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:05:04 -0700 (PDT)
Message-ID: <55BB8E97.4040005@redhat.com>
Date: Fri, 31 Jul 2015 17:04:55 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 27/36] mm: differentiate page_mapped() from page_mapcount()
 for compound pages
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-28-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="cKN1r8KnNfCxoBcaFp7GBSMTRBG7pl9SD"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cKN1r8KnNfCxoBcaFp7GBSMTRBG7pl9SD
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> Let's define page_mapped() to be true for compound pages if any
> sub-pages of the compound page is mapped (with PMD or PTE).
>=20
> On other hand page_mapcount() return mapcount for this particular small=

> page.
>=20
> This will make cases like page_get_anon_vma() behave correctly once we
> allow huge pages to be mapped with PTE.
>=20
> Most users outside core-mm should use page_mapcount() instead of
> page_mapped().
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  arch/arc/mm/cache_arc700.c |  4 ++--
>  arch/arm/mm/flush.c        |  2 +-
>  arch/mips/mm/c-r4k.c       |  3 ++-
>  arch/mips/mm/cache.c       |  2 +-
>  arch/mips/mm/init.c        |  6 +++---
>  arch/sh/mm/cache-sh4.c     |  2 +-
>  arch/sh/mm/cache.c         |  8 ++++----
>  arch/xtensa/mm/tlb.c       |  2 +-
>  fs/proc/page.c             |  4 ++--
>  include/linux/mm.h         | 15 +++++++++++++--
>  mm/filemap.c               |  2 +-
>  11 files changed, 31 insertions(+), 19 deletions(-)
>=20



--cKN1r8KnNfCxoBcaFp7GBSMTRBG7pl9SD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu46XAAoJEHTzHJCtsuoC7NYH+wQJJZuesz/OeAscJ/zrPvSE
saj4QT33ICzOb9W0C/tFUOQhYn0WWS8GIQXErU5N5PuTfx/mgw0WK/hENaRmLADO
fP6XLdh8fmCtexS9UFOLv69dIcMYV4rUqFEaJ2qeGwVe/9ymLov2RS2gvAFFiey2
u6ibm4Dg7avYiZfvqzozak30MYwIsZlYRsznV6amiC0nhaEpUkWTffXD0+Y28Ha1
7vOgn6IFV37uUb0o2Y9c+Y1NlmuEnshT2aKmrlTxo83UMqYzrFduLFJyWOBcygIu
uWFbmkupLz/wiHlf0It3PS1FhbaXkdJFXoKofO4Gnp3VQ4tbGBJ/bVsDQZz0s+I=
=fCYg
-----END PGP SIGNATURE-----

--cKN1r8KnNfCxoBcaFp7GBSMTRBG7pl9SD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
