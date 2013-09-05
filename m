From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/thp: fix comments in transparent_hugepage_flags
Date: Thu, 5 Sep 2013 10:11:45 +0800
Message-ID: <48410.5076328435$1378347132@news.gmane.org>
References: <1378301422-9468-1-git-send-email-wujianguo@huawei.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VHP39-0006ah-Ok
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Sep 2013 04:12:00 +0200
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id A72006B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 22:11:56 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 07:33:43 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id AFCD6E0054
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 07:42:31 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r852DZRK32112892
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 07:43:35 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r852Bkqo029340
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 07:41:46 +0530
Content-Disposition: inline
In-Reply-To: <1378301422-9468-1-git-send-email-wujianguo@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo106@gmail.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jianguo Wu <wujianguo@huawei.com>

Hi Jianguo,
On Wed, Sep 04, 2013 at 09:30:22PM +0800, Jianguo Wu wrote:
>Since commit d39d33c332(thp: enable direct defrag), defrag is enable
>for all transparent hugepage page faults by default, not only in
>MADV_HUGEPAGE regions.
>
>Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>---
> mm/huge_memory.c | 6 ++----
> 1 file changed, 2 insertions(+), 4 deletions(-)
>
>diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>index a92012a..abf047e 100644
>--- a/mm/huge_memory.c
>+++ b/mm/huge_memory.c
>@@ -28,10 +28,8 @@
>
> /*
>  * By default transparent hugepage support is enabled for all mappings

This is also stale. TRANSPARENT_HUGEPAGE_ALWAYS is not configured by default in
order that avoid to risk increase the memory footprint of applications w/o a 
guaranteed benefit.

Regards,
Wanpeng Li 

>- * and khugepaged scans all mappings. Defrag is only invoked by
>- * khugepaged hugepage allocations and by page faults inside
>- * MADV_HUGEPAGE regions to avoid the risk of slowing down short lived
>- * allocations.
>+ * and khugepaged scans all mappings. Defrag is invoked by khugepaged
>+ * hugepage allocations and by page faults for all hugepage allocations.
>  */
> unsigned long transparent_hugepage_flags __read_mostly =
> #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
>-- 
>1.8.1.2
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
