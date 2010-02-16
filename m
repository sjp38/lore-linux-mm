Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C82716B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 20:14:06 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o1G1E2aW001099
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:14:03 -0800
Received: from pzk39 (pzk39.prod.google.com [10.243.19.167])
	by kpbe16.cbf.corp.google.com with ESMTP id o1G1E18R023674
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:14:01 -0800
Received: by pzk39 with SMTP id 39so6194382pzk.15
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:14:01 -0800 (PST)
Date: Mon, 15 Feb 2010 17:13:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: add comment about deprecation of __GFP_NOFAIL
In-Reply-To: <20100216092147.85ef7619.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002151712290.23480@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com> <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
 <20100216092147.85ef7619.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > As I already explained when you first brought this up, the possibility of 
> > not invoking the oom killer is not unique to GFP_DMA, it is also possible 
> > for GFP_NOFS.  Since __GFP_NOFAIL is deprecated and there are no current 
> > users of GFP_DMA | __GFP_NOFAIL, that warning is completely unnecessary.  
> > We're not adding any additional __GFP_NOFAIL allocations.
> >
> 
> Please add documentation about that to gfp.h before doing this.
> Doing this without writing any documenation is laziness.
> (WARNING is a style of documentation.)
> 

This is already documented in the page allocator, but I guess doing it in 
include/linux/gfp.h as well doesn't hurt.



mm: add comment about deprecation of __GFP_NOFAIL

__GFP_NOFAIL was deprecated in dab48dab, so add a comment that no new 
users should be added.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/gfp.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -30,7 +30,8 @@ struct vm_area_struct;
  * _might_ fail.  This depends upon the particular VM implementation.
  *
  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
- * cannot handle allocation failures.
+ * cannot handle allocation failures.  This modifier is deprecated and no new
+ * users should be added.
  *
  * __GFP_NORETRY: The VM implementation must not retry indefinitely.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
