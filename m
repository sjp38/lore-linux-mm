Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6884C6B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 04:52:48 -0400 (EDT)
Date: Wed, 24 Jul 2013 17:52:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 03/10] mm, hugetlb: trivial commenting fix
Message-ID: <20130724085255.GE2266@lge.com>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1374482191-3500-4-git-send-email-iamjoonsoo.kim@lge.com>
 <51ef274e.0605e00a.246a.ffffa5c9SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ef274e.0605e00a.246a.ffffa5c9SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 24, 2013 at 09:00:41AM +0800, Wanpeng Li wrote:
> On Mon, Jul 22, 2013 at 05:36:24PM +0900, Joonsoo Kim wrote:
> >The name of the mutex written in comment is wrong.
> >Fix it.
> >
> >Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >Acked-by: Hillf Danton <dhillf@gmail.com>
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >index d87f70b..d21a33a 100644
> >--- a/mm/hugetlb.c
> >+++ b/mm/hugetlb.c
> >@@ -135,9 +135,9 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
> >  *                    across the pages in a mapping.
> >  *
> >  * The region data structures are protected by a combination of the mmap_sem
> >- * and the hugetlb_instantion_mutex.  To access or modify a region the caller
> >+ * and the hugetlb_instantiation_mutex.  To access or modify a region the caller
> >  * must either hold the mmap_sem for write, or the mmap_sem for read and
> >- * the hugetlb_instantiation mutex:
> >+ * the hugetlb_instantiation_mutex:
> 
> What changed?

hugetlb_instantiation_mutex
                     ^ here!

Thanks for review!

> 
> >  *
> >  *	down_write(&mm->mmap_sem);
> >  * or
> >-- 
> >1.7.9.5
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
