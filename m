Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAFA82F64
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 11:09:41 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so53506721pad.3
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:09:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sp4si14187340pac.151.2015.09.18.08.02.25
        for <linux-mm@kvack.org>;
        Fri, 18 Sep 2015 08:02:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv11 35/37] mm: re-enable THP
Date: Fri, 18 Sep 2015 18:01:38 +0300
Message-Id: <1442588500-77331-36-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1442588500-77331-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1442588500-77331-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

All parts of THP with new refcounting are now in place. We can now allow
to enable THP.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 45edc5a989ee..b9fb7a76a51d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -398,7 +398,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
-	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE && BROKEN
+	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select COMPACTION
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
