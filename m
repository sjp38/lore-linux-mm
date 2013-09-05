From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mempool: Convert kmalloc_node(...GFP_ZERO...) to
 kzalloc_node(...)
Date: Thu, 5 Sep 2013 13:51:43 +0800
Message-ID: <4079.72995094514$1378360320@news.gmane.org>
References: <19f4bf138da20276466d4ae66f8704e762d3e0f0.1377815411.git.joe@perches.com>
 <f172c1f3d71f879d8864ce0374988624c35691ca.1377815411.git.joe@perches.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VHSTx-0004f5-Qa
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Sep 2013 07:51:54 +0200
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B523A6B0036
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 01:51:51 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 11:12:26 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id F0DA43940059
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 11:21:33 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r855phcZ46858276
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 11:21:43 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r855pjUP028227
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 11:21:45 +0530
Content-Disposition: inline
In-Reply-To: <f172c1f3d71f879d8864ce0374988624c35691ca.1377815411.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Aug 29, 2013 at 03:31:19PM -0700, Joe Perches wrote:
>Use the helper function instead of __GFP_ZERO.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Joe Perches <joe@perches.com>
>---
> mm/mempool.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/mempool.c b/mm/mempool.c
>index 5499047..659aa42 100644
>--- a/mm/mempool.c
>+++ b/mm/mempool.c
>@@ -73,7 +73,7 @@ mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
> 			       gfp_t gfp_mask, int node_id)
> {
> 	mempool_t *pool;
>-	pool = kmalloc_node(sizeof(*pool), gfp_mask | __GFP_ZERO, node_id);
>+	pool = kzalloc_node(sizeof(*pool), gfp_mask, node_id);
> 	if (!pool)
> 		return NULL;
> 	pool->elements = kmalloc_node(min_nr * sizeof(void *),
>-- 
>1.8.1.2.459.gbcd45b4.dirty
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
