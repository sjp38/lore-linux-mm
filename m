Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 3D63C6B003D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 05:30:32 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 21 Aug 2013 14:51:28 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 3CD41E0056
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:00:56 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7L9VtsT44105858
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:01:55 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7L9UPhG009312
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:00:26 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 04/20] mm, hugetlb: remove useless check about mapping type
In-Reply-To: <1376040398-11212-5-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-5-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 21 Aug 2013 15:00:24 +0530
Message-ID: <87siy3gzm7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> is_vma_resv_set(vma, HPAGE_RESV_OWNER) implys that this mapping is
> for private. So we don't need to check whether this mapping is for
> shared or not.
>
> This patch is just for clean-up.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ea1ae0a..c017c52 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2544,8 +2544,7 @@ retry_avoidcopy:
>  	 * at the time of fork() could consume its reserves on COW instead
>  	 * of the full address range.
>  	 */
> -	if (!(vma->vm_flags & VM_MAYSHARE) &&
> -			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
> +	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
>  			old_page != pagecache_page)
>  		outside_reserve = 1;
>
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
