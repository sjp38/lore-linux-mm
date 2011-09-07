Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 995AD6B016C
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 23:09:06 -0400 (EDT)
Subject: Re: [PATCH] slub: correct comments error for per cpu partial
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1109061914440.18646@router.home>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Sep 2011 11:14:48 +0800
Message-ID: <1315365288.31737.188.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On Wed, 2011-09-07 at 08:14 +0800, Christoph Lameter wrote:
> On Mon, 5 Sep 2011, Alex,Shi wrote:
> 
> > I found 2 comments error base your per cpu partial patches. Could you
> > like to review for the correction of them?
> 
> Great. Thank you.
Thanks for review. I try to add a little bit formal commit info, but
seems hard to say more. :) how about the following?  

=========

Correct 2 comments errors for per cpu partial patches. 

Signed-off-by: Alex Shi <alex.shi@intel.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slub_def.h |    2 +-
 mm/slub.c                |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 4890ef7..a32bcfd 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -82,7 +82,7 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
-	int cpu_partial;	/* Number of per cpu partial pages to keep around */
+	int cpu_partial;	/* Number of per cpu partial objects to keep around */
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
diff --git a/mm/slub.c b/mm/slub.c
index 0e286ac..ebb3865 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3086,7 +3086,7 @@ static int kmem_cache_open(struct kmem_cache *s,
 	 *
 	 * A) The number of objects from per cpu partial slabs dumped to the
 	 *    per node list when we reach the limit.
-	 * B) The number of objects in partial partial slabs to extract from the
+	 * B) The number of objects in cpu partial slabs to extract from the
 	 *    per node list when we run out of per cpu objects. We only fetch 50%
 	 *    to keep some capacity around for frees.
 	 */
-- 
1.7.0




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
