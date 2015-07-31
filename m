Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id E24986B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:15:04 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so30109603qkd.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:15:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d83si6122645qhc.96.2015.07.31.08.15.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:15:04 -0700 (PDT)
Message-ID: <55BB90F1.9000809@redhat.com>
Date: Fri, 31 Jul 2015 17:14:57 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 34/36] thp: introduce deferred_split_huge_page()
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-35-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-35-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="MwuDhwB3VxfBQKH7xgSpPENe9frpHfQn1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MwuDhwB3VxfBQKH7xgSpPENe9frpHfQn1
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> Currently we don't split huge page on partial unmap. It's not an ideal
> situation. It can lead to memory overhead.
>=20
> Furtunately, we can detect partial unmap on page_remove_rmap(). But we
> cannot call split_huge_page() from there due to locking context.
>=20
> It's also counterproductive to do directly from munmap() codepath: in
> many cases we will hit this from exit(2) and splitting the huge page
> just to free it up in small pages is not what we really want.
>=20
> The patch introduce deferred_split_huge_page() which put the huge page
> into queue for splitting. The splitting itself will happen when we get
> memory pressure via shrinker interface. The page will be dropped from
> list on freeing through compound page destructor.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/huge_mm.h |   4 ++
>  include/linux/mm.h      |   2 +
>  mm/huge_memory.c        | 127 ++++++++++++++++++++++++++++++++++++++++=
++++++--
>  mm/migrate.c            |   1 +
>  mm/page_alloc.c         |   2 +-
>  mm/rmap.c               |   7 ++-
>  6 files changed, 138 insertions(+), 5 deletions(-)
>



--MwuDhwB3VxfBQKH7xgSpPENe9frpHfQn1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu5DxAAoJEHTzHJCtsuoCXYcH/2IGPhHNhM4MrfV347UtebNZ
7fsu27iZasrpeyGBZeNGXqkAEABTa33CS4VQwuYgzdJm0NT5QMCQcpZqRFFw9b3/
dh6u4xp+LeATZ1wLq6BLliEV3/2SfpygBExAy7cgurSJER2pDoBlKt1zJvvAV/zg
Vcurwtyi8JFzOErHncbE0zgHqGmnoyTnF4vH599izsp/e7x/vJOdLoWoAne+s8Pz
WG5vHZVKUvswE+nPokXODN+XcdrFA+UFVu9VXqxLsbV6GGXpz2M9MMn2r0N37Ppj
LYLmv0lKGBF1H+7gnBrRiZQKbW9HIH61G9FsA5E6dVcJTDr2P7Da8BCVMlUPxnY=
=/tP5
-----END PGP SIGNATURE-----

--MwuDhwB3VxfBQKH7xgSpPENe9frpHfQn1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
