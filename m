Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3C66B007B
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:47:25 -0400 (EDT)
Received: by padev16 with SMTP id ev16so7495219pad.0
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:47:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id l9si34766250pdj.235.2015.06.23.06.47.14
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 11/36] mm: temporally mark THP broken
Date: Tue, 23 Jun 2015 16:46:21 +0300
Message-Id: <1435067206-92901-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Up to this point we tried to keep patchset bisectable, but next patches
are going to change how core of THP refcounting work.

It would be beneficial to split the change into several patches and make
it more reviewable. Unfortunately, I don't see how we can achieve that
while keeping THP working.

Let's hide THP under CONFIG_BROKEN for now and bring it back when new
refcounting get established.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index e79de2bd12cd..c973f416cbe5 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -410,7 +410,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
-	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE && BROKEN
 	select COMPACTION
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
