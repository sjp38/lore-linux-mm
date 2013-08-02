Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 4BFC46B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 04:14:15 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 2 Aug 2013 13:33:57 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 0E89B1258052
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 13:43:39 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r728F97I32702654
	for <linux-mm@kvack.org>; Fri, 2 Aug 2013 13:45:12 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r728E3nB012849
	for <linux-mm@kvack.org>; Fri, 2 Aug 2013 18:14:04 +1000
Date: Fri, 2 Aug 2013 16:14:01 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm, vmalloc: remove useless variable in vmap_block
Message-ID: <20130802081401.GA14447@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Aug 02, 2013 at 10:57:00AM +0900, Joonsoo Kim wrote:
>vbq in vmap_block isn't used. So remove it.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>index 13a5495..d23c432 100644
>--- a/mm/vmalloc.c
>+++ b/mm/vmalloc.c
>@@ -752,7 +752,6 @@ struct vmap_block_queue {
> struct vmap_block {
> 	spinlock_t lock;
> 	struct vmap_area *va;
>-	struct vmap_block_queue *vbq;
> 	unsigned long free, dirty;
> 	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
> 	struct list_head free_list;
>@@ -830,7 +829,6 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
> 	radix_tree_preload_end();
>
> 	vbq = &get_cpu_var(vmap_block_queue);
>-	vb->vbq = vbq;
> 	spin_lock(&vbq->lock);
> 	list_add_rcu(&vb->free_list, &vbq->free);
> 	spin_unlock(&vbq->lock);
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
