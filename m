Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DA7C86B00C3
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 07:08:41 -0400 (EDT)
Date: Wed, 12 Sep 2012 12:08:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120912110837.GN11266@suse.de>
References: <20120910011830.GC3715@kernel.org>
 <20120911163455.bb249a3c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120911163455.bb249a3c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, aarcange@redhat.com

On Tue, Sep 11, 2012 at 04:34:55PM -0700, Andrew Morton wrote:
> Alas, try_to_compact_pages()'s kerneldoc altogether forgets to describe
> this argument.  Mel's
> mm-compaction-capture-a-suitable-high-order-page-immediately-when-it-is-made-available.patch
> adds a `pages' arg and forgets to document that as well.
> 

*slaps*

This covers both of them.

---8<---
mm: compaction: Update try_to_compact_pages kernel doc comment

Parameters were added without documentation, tut tut.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 364e12f..614f18b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -919,6 +919,8 @@ int sysctl_extfrag_threshold = 500;
  * @gfp_mask: The GFP mask of the current allocation
  * @nodemask: The allowed nodes to allocate from
  * @sync: Whether migration is synchronous or not
+ * @contended: Return value that is true if compaction was aborted due to lock contention
+ * @page: Optionally capture a free page of the requested order during compaction
  *
  * This is the main entry point for direct page compaction.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
