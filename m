From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm/thp: fix stale comments of
 transparent_hugepage_flags
Date: Thu, 5 Sep 2013 16:09:19 +0800
Message-ID: <30545.0126565576$1378368579@news.gmane.org>
References: <5228397B.9000502@huawei.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VHUd8-0004IM-9J
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Sep 2013 10:09:30 +0200
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 430976B0036
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 04:09:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 13:30:02 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 191361258043
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 13:39:19 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8589I8f42664178
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 13:39:18 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8589K30015492
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 13:39:20 +0530
Content-Disposition: inline
In-Reply-To: <5228397B.9000502@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, Mel Gorman <mgorman@suse.de>, xiaoguangrong@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 05, 2013 at 03:57:47PM +0800, Jianguo Wu wrote:
>Changelog:
> *v1 -> v2: also update the stale comments about default transparent
>hugepage support pointed by Wanpeng Li.
>
>Since commit 13ece886d9(thp: transparent hugepage config choice),
>transparent hugepage support is disabled by default, and
>TRANSPARENT_HUGEPAGE_ALWAYS is configured when TRANSPARENT_HUGEPAGE=y.
>
>And since commit d39d33c332(thp: enable direct defrag), defrag is
>enable for all transparent hugepage page faults by default, not only in
>MADV_HUGEPAGE regions.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>---
> mm/huge_memory.c |   12 ++++++------
> 1 files changed, 6 insertions(+), 6 deletions(-)
>
>diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>index a92012a..0e42a70 100644
>--- a/mm/huge_memory.c
>+++ b/mm/huge_memory.c
>@@ -26,12 +26,12 @@
> #include <asm/pgalloc.h>
> #include "internal.h"
>
>-/*
>- * By default transparent hugepage support is enabled for all mappings
>- * and khugepaged scans all mappings. Defrag is only invoked by
>- * khugepaged hugepage allocations and by page faults inside
>- * MADV_HUGEPAGE regions to avoid the risk of slowing down short lived
>- * allocations.
>+/* By default transparent hugepage support is disabled in order that avoid
>+ * to risk increase the memory footprint of applications without a guaranteed
>+ * benefit. When transparent hugepage support is enabled, is for all mappings,
>+ * and khugepaged scans all mappings.
>+ * Defrag is invoked by khugepaged hugepage allocations and by page faults
>+ * for all hugepage allocations.
>  */
> unsigned long transparent_hugepage_flags __read_mostly =
> #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
>-- 
>1.7.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
