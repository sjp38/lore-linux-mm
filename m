Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D4A66B0047
	for <linux-mm@kvack.org>; Sat,  9 May 2009 04:18:52 -0400 (EDT)
Date: Sat, 9 May 2009 16:18:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/8] pagemap: document 9 more exported page flags
Message-ID: <20090509081842.GA8168@localhost>
References: <20090508105320.316173813@intel.com> <20090508111031.568178884@intel.com> <20090509171125.8D08.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509171125.8D08.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 09, 2009 at 04:13:40PM +0800, KOSAKI Motohiro wrote:
> > Also add short descriptions for all of the 20 exported page flags.
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  Documentation/vm/pagemap.txt |   62 +++++++++++++++++++++++++++++++++
> >  1 file changed, 62 insertions(+)
> > 
> > --- linux.orig/Documentation/vm/pagemap.txt
> > +++ linux/Documentation/vm/pagemap.txt
> > @@ -49,6 +49,68 @@ There are three components to pagemap:
> >       8. WRITEBACK
> >       9. RECLAIM
> >      10. BUDDY
> > +    11. MMAP
> > +    12. ANON
> > +    13. SWAPCACHE
> > +    14. SWAPBACKED
> > +    15. COMPOUND_HEAD
> > +    16. COMPOUND_TAIL
> > +    16. HUGE
> 
> nit. 16 appear twice.

Good catch!

Andrew, this fix can be folded into the last patch.
---
pagemap: fix HUGE numbering

Thanks to KOSAKI Motohiro for catching this.

cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/vm/pagemap.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/Documentation/vm/pagemap.txt
+++ linux/Documentation/vm/pagemap.txt
@@ -55,7 +55,7 @@ There are three components to pagemap:
     14. SWAPBACKED
     15. COMPOUND_HEAD
     16. COMPOUND_TAIL
-    16. HUGE
+    17. HUGE
     18. UNEVICTABLE
     19. HWPOISON
     20. NOPAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
