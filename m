Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 09C816B0254
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:51:53 -0400 (EDT)
Received: by qged69 with SMTP id d69so47196071qge.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:51:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q42si6026855qkh.117.2015.07.31.07.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:51:52 -0700 (PDT)
Message-ID: <55BB8B81.5030904@redhat.com>
Date: Fri, 31 Jul 2015 16:51:45 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 13/36] mm: drop tail page refcounting
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-14-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xx3CWnb6KwdlmaRsBXgsoBIagJpT3B1cd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xx3CWnb6KwdlmaRsBXgsoBIagJpT3B1cd
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> Tail page refcounting is utterly complicated and painful to support.
>=20
> It uses ->_mapcount on tail pages to store how many times this page is
> pinned. get_page() bumps ->_mapcount on tail page in addition to
> ->_count on head. This information is required by split_huge_page() to
> be able to distribute pins from head of compound page to tails during
> the split.
>=20
> We will need ->_mapcount to account PTE mappings of subpages of the
> compound page. We eliminate need in current meaning of ->_mapcount in
> tail pages by forbidding split entirely if the page is pinned.
>=20
> The only user of tail page refcounting is THP which is marked BROKEN fo=
r
> now.
>=20
> Let's drop all this mess. It makes get_page() and put_page() much
> simpler.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  arch/mips/mm/gup.c            |   4 -
>  arch/powerpc/mm/hugetlbpage.c |  13 +-
>  arch/s390/mm/gup.c            |  13 +-
>  arch/sparc/mm/gup.c           |  14 +--
>  arch/x86/mm/gup.c             |   4 -
>  include/linux/mm.h            |  47 ++------
>  include/linux/mm_types.h      |  17 +--
>  mm/gup.c                      |  34 +-----
>  mm/huge_memory.c              |  41 +------
>  mm/hugetlb.c                  |   2 +-
>  mm/internal.h                 |  44 -------
>  mm/swap.c                     | 273 +++-------------------------------=
--------
>  12 files changed, 40 insertions(+), 466 deletions(-)
>=20



--xx3CWnb6KwdlmaRsBXgsoBIagJpT3B1cd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4uBAAoJEHTzHJCtsuoCoSMH/RC/90otzHeGxEJbQVU91ffO
ESX1zg2XbiTYFiTlYlwikb/s5AjMg9WvF6UI8THl1eY04b2ybIvzJjAK3QkdT0YA
RixbpOejf9HamG4GtSx5HjUEi/q7n95GPA/o6yvdNLKu+nYcAQXkysvuqy191B8r
qD+vKamNg88XkE9NG1uFloPko/zu7PawMzKluVyL7EQpfKGD5oEKSMzsEv3X/n6I
N7SqdrW4E+XLMIpv1JwSbNlnEySzMHxgVcDA1sXlHFy+PEVQSAvgpghcptveXtO2
wc3JdH+YXKNpbyWqG7mZGKnnkDxf1BVVqK3ujdc9wlzaYsvpRQ1zW+MtprUMuqY=
=ABSG
-----END PGP SIGNATURE-----

--xx3CWnb6KwdlmaRsBXgsoBIagJpT3B1cd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
