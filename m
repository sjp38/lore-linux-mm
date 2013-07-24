From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/8] migrate: remove VM_HUGETLB from vma flag check in
 vma_migratable()
Date: Wed, 24 Jul 2013 11:45:54 +0800
Message-ID: <1194.27938848293$1374637575@news.gmane.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1q1d-0005ux-Po
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 05:46:06 +0200
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 566F56B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:46:03 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 09:07:58 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id DF504E0054
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:15:57 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O3jr5B41156710
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:15:53 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O3jusP004994
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:45:56 +1000
Content-Disposition: inline
In-Reply-To: <1374183272-10153-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:30PM -0400, Naoya Horiguchi wrote:
>This patch enables hugepage migration from migrate_pages(2),
>move_pages(2), and mbind(2).
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> include/linux/mempolicy.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git v3.11-rc1.orig/include/linux/mempolicy.h v3.11-rc1/include/linux/mempolicy.h
>index 0d7df39..2e475b5 100644
>--- v3.11-rc1.orig/include/linux/mempolicy.h
>+++ v3.11-rc1/include/linux/mempolicy.h
>@@ -173,7 +173,7 @@ extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
> /* Check if a vma is migratable */
> static inline int vma_migratable(struct vm_area_struct *vma)
> {
>-	if (vma->vm_flags & (VM_IO | VM_HUGETLB | VM_PFNMAP))
>+	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
> 		return 0;
> 	/*
> 	 * Migration allocates pages in the highest zone. If we cannot
>-- 
>1.8.3.1
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
