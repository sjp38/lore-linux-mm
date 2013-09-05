Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D525E6B0034
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 01:50:30 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 11:10:23 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 35B15394004E
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 11:20:09 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r855oJTk40239228
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 11:20:19 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r855oKuX026197
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 11:20:20 +0530
Date: Thu, 5 Sep 2013 13:50:19 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] ksm: Remove redundant __GFP_ZERO from kcalloc
Message-ID: <20130905055018.GA28562@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1c47ec33fcbbf393f8d6decc9b3d6e18ed8b09a1.1377819069.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1c47ec33fcbbf393f8d6decc9b3d6e18ed8b09a1.1377819069.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Aug 29, 2013 at 04:32:14PM -0700, Joe Perches wrote:
>kcalloc returns zeroed memory.
>There's no need to use this flag.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Joe Perches <joe@perches.com>
>---
> mm/ksm.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/mm/ksm.c b/mm/ksm.c
>index 0bea2b2..175fff7 100644
>--- a/mm/ksm.c
>+++ b/mm/ksm.c
>@@ -2309,8 +2309,8 @@ static ssize_t merge_across_nodes_store(struct kobject *kobj,
> 			 * Allocate stable and unstable together:
> 			 * MAXSMP NODES_SHIFT 10 will use 16kB.
> 			 */
>-			buf = kcalloc(nr_node_ids + nr_node_ids,
>-				sizeof(*buf), GFP_KERNEL | __GFP_ZERO);
>+			buf = kcalloc(nr_node_ids + nr_node_ids, sizeof(*buf),
>+				      GFP_KERNEL);
> 			/* Let us assume that RB_ROOT is NULL is zero */
> 			if (!buf)
> 				err = -ENOMEM;
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
