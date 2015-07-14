Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5EE280246
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 10:03:22 -0400 (EDT)
Received: by pacan13 with SMTP id an13so6389862pac.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 07:03:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f10si1925449pdp.225.2015.07.14.07.03.21
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 07:03:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-17-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436550130-112636-17-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 16/36] mm, thp: remove compound_lock
Content-Transfer-Encoding: 7bit
Message-Id: <20150714140244.C85BE8B@black.fi.intel.com>
Date: Tue, 14 Jul 2015 17:02:44 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> We are going to use migration entries to stabilize page counts. It means
> we don't need compound_lock() for that.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/mm.h         | 35 -----------------------------------
>  include/linux/page-flags.h | 12 +-----------
>  mm/debug.c                 |  3 ---
>  mm/memcontrol.c            | 11 +++--------
>  4 files changed, 4 insertions(+), 57 deletions(-)

checkpatch fixlet:

22a36e559f70  mm, thp: remove compound_lock fix
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74b7cece1dfa..f10f9c0030dd 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -689,7 +689,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON )
+	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
