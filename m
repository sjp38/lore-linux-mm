Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 3F6C26B0037
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 10:02:56 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 19:26:00 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 16CFC394005B
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 19:32:44 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6FE2OIa21561482
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 19:32:25 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6FE2RX8011318
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 00:02:28 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/9] mm, hugetlb: trivial commenting fix
In-Reply-To: <1373881967-16153-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com> <1373881967-16153-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 15 Jul 2013 19:32:24 +0530
Message-ID: <877ggrkjkf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> The name of the mutex written in comment is wrong.
> Fix it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
 
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d87f70b..d21a33a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -135,9 +135,9 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
>   *                    across the pages in a mapping.
>   *
>   * The region data structures are protected by a combination of the mmap_sem
> - * and the hugetlb_instantion_mutex.  To access or modify a region the caller
> + * and the hugetlb_instantiation_mutex.  To access or modify a region the caller
>   * must either hold the mmap_sem for write, or the mmap_sem for read and
> - * the hugetlb_instantiation mutex:
> + * the hugetlb_instantiation_mutex:
>   *
>   *	down_write(&mm->mmap_sem);
>   * or
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
