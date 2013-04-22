Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 090386B0032
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 07:08:05 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <5171d291.z0O+vFet0jlVHN9L%fengguang.wu@intel.com>
References: <5171d291.z0O+vFet0jlVHN9L%fengguang.wu@intel.com>
Subject: RE: [next:akpm 522/1000] mm/huge_memory.c:189:24: sparse: Using plain
 integer as NULL pointer
Content-Transfer-Encoding: 7bit
Message-Id: <20130422111010.61A20E0085@blue.fi.intel.com>
Date: Mon, 22 Apr 2013 14:10:10 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kbuild test robot <fengguang.wu@intel.com>, linux-mm@kvack.org

kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
> head:   c9941b7ec7840ad33f5822c7f238157558d40132
> commit: 4b4928dfcbe7f45ab9a900de1e0847cc555fc935 [522/1000] thp: fix huge zero page logic for page with pfn == 0
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
> >> mm/huge_memory.c:189:24: sparse: Using plain integer as NULL pointer

Thanks for report. The fix is below.
Andrew, could you fold it into original patch?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bc2a548..d46ea1e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -186,7 +186,7 @@ retry:
 			HPAGE_PMD_ORDER);
 	if (!zero_page) {
 		count_vm_event(THP_ZERO_PAGE_ALLOC_FAILED);
-		return 0;
+		return NULL;
 	}
 	count_vm_event(THP_ZERO_PAGE_ALLOC);
 	preempt_disable();
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
