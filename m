From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 06/10] mm, hugetlb: remove redundant list_empty check
 in gather_surplus_pages()
Date: Wed, 24 Jul 2013 09:12:16 +0800
Message-ID: <14587.4595073566$1374628358@news.gmane.org>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1374482191-3500-7-git-send-email-iamjoonsoo.kim@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1ncy-0008Pu-S6
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 03:12:29 +0200
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 64D256B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 21:12:26 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 06:34:27 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id DB319E0057
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:42:19 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O1DAUv39321710
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:43:10 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O1CHcp024324
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:12:18 +1000
Content-Disposition: inline
In-Reply-To: <1374482191-3500-7-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jul 22, 2013 at 05:36:27PM +0900, Joonsoo Kim wrote:
>If list is empty, list_for_each_entry_safe() doesn't do anything.
>So, this check is redundant. Remove it.
>
>Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index 3ac0a6f..7ca8733 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -1017,11 +1017,8 @@ free:
> 	spin_unlock(&hugetlb_lock);
>
> 	/* Free unnecessary surplus pages to the buddy allocator */
>-	if (!list_empty(&surplus_list)) {
>-		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
>-			put_page(page);
>-		}
>-	}
>+	list_for_each_entry_safe(page, tmp, &surplus_list, lru)
>+		put_page(page);
> 	spin_lock(&hugetlb_lock);
>
> 	return ret;
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
