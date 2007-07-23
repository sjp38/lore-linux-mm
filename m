Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070723112143.GB19437@skynet.ie>
References: <1185185020.8197.11.camel@twins>
	 <20070723112143.GB19437@skynet.ie>
Content-Type: text/plain
Date: Mon, 23 Jul 2007 13:38:31 +0200
Message-Id: <1185190711.8197.15.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-23 at 12:21 +0100, Mel Gorman wrote:

> Does this patch compile though?

Ugh, the fix landed in another patch :-(

updated patch below.

---
Daniel recently spotted that __GFP_ZERO is not (and has never been)
part of GFP_LEVEL_MASK. I could not find a reason for this in the
original patch: 3977971c7f09ce08ed1b8d7a67b2098eb732e4cd in the -bk
tree.

This of course is in stark contradiction with the comment accompanying
GFP_LEVEL_MASK.
---
 include/linux/gfp.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-2/include/linux/gfp.h
===================================================================
--- linux-2.6-2.orig/include/linux/gfp.h
+++ linux-2.6-2/include/linux/gfp.h
@@ -56,7 +56,7 @@ struct vm_area_struct;
 /* if you forget to add the bitmask here kernel will crash, period */
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
-			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP| \
+			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP|__GFP_ZERO| \
 			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
 			__GFP_MOVABLE)
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
