Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 72F6B6B0033
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 10:46:34 -0400 (EDT)
Date: Mon, 22 Jul 2013 16:46:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/9] mm, hugetlb: trivial commenting fix
Message-ID: <20130722144632.GE24400@dhcp22.suse.cz>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373881967-16153-3-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon 15-07-13 18:52:40, Joonsoo Kim wrote:
> The name of the mutex written in comment is wrong.
> Fix it.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

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
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
