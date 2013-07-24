From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 03/10] mm, hugetlb: trivial commenting fix
Date: Wed, 24 Jul 2013 09:00:41 +0800
Message-ID: <39343.0067379542$1374627672@news.gmane.org>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1374482191-3500-4-git-send-email-iamjoonsoo.kim@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1nRt-0001vc-Kk
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 03:01:01 +0200
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 500CD6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 21:00:59 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 06:21:54 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 825B6E0059
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:30:54 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O11iJD21037182
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:31:45 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O10mKk030930
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:00:51 +1000
Content-Disposition: inline
In-Reply-To: <1374482191-3500-4-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jul 22, 2013 at 05:36:24PM +0900, Joonsoo Kim wrote:
>The name of the mutex written in comment is wrong.
>Fix it.
>
>Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>Acked-by: Hillf Danton <dhillf@gmail.com>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index d87f70b..d21a33a 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -135,9 +135,9 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
>  *                    across the pages in a mapping.
>  *
>  * The region data structures are protected by a combination of the mmap_sem
>- * and the hugetlb_instantion_mutex.  To access or modify a region the caller
>+ * and the hugetlb_instantiation_mutex.  To access or modify a region the caller
>  * must either hold the mmap_sem for write, or the mmap_sem for read and
>- * the hugetlb_instantiation mutex:
>+ * the hugetlb_instantiation_mutex:

What changed?

>  *
>  *	down_write(&mm->mmap_sem);
>  * or
>-- 
>1.7.9.5
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
