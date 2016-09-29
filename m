Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93F19280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:16:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t83so202598205oie.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:16:05 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id 110si6335252otg.144.2016.09.28.23.16.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 23:16:05 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 0/3] mm/hugetlb: memory offline issues with hugepages
Date: Thu, 29 Sep 2016 06:14:36 +0000
Message-ID: <20160929061435.GA3073@hori1.linux.bs1.fc.nec.co.jp>
References: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
In-Reply-To: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F7504E4B70C9E74D8161CB932595D4F8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Sep 26, 2016 at 07:28:08PM +0200, Gerald Schaefer wrote:
> This addresses several issues with hugepages and memory offline. While
> the first patch fixes a panic, and is therefore rather important, the
> last patch is just a performance optimization.
>=20
> The second patch fixes a theoretical issue with reserved hugepages,
> while still leaving some ugly usability issue, see description.
>=20
> Changes in v4:
> - Add check for free vs. reserved hugepages
> - Revalidate checks in dissolve_free_huge_page() after taking the lock
> - Split up into 3 patches
>=20
> Changes in v3:
> - Add Fixes: c8721bbb
> - Add Cc: stable
> - Elaborate on losing the gigantic page vs. failing memory offline
> - Move page_count() check out of dissolve_free_huge_page()
>=20
> Changes in v2:
> - Update comment in dissolve_free_huge_pages()
> - Change locking in dissolve_free_huge_page()
>=20
> Gerald Schaefer (3):
>   mm/hugetlb: fix memory offline with hugepage size > memory block size
>   mm/hugetlb: check for reserved hugepages during memory offline
>   mm/hugetlb: improve locking in dissolve_free_huge_pages()
>=20
>  include/linux/hugetlb.h |  6 +++---
>  mm/hugetlb.c            | 47 +++++++++++++++++++++++++++++++++++--------=
----
>  mm/memory_hotplug.c     |  4 +++-
>  3 files changed, 41 insertions(+), 16 deletions(-)

I'm happy with these patches fixing/improving hugetlb offline code,
thank you very much, Gerald and reviewers/testers!

For patchset ...

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
