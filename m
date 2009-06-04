Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3E66B004F
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 01:14:34 -0400 (EDT)
Date: Thu, 4 Jun 2009 07:21:47 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [9/16] HWPOISON: Handle hardware poisoned pages in try_to_unmap
Message-ID: <20090604052147.GP1065@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184642.BD4B91D0291@basil.firstfloor.org> <20090604043541.GC15682@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604043541.GC15682@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Index: linux/include/linux/rmap.h
> > ===================================================================
> > --- linux.orig/include/linux/rmap.h	2009-06-03 19:36:23.000000000 +0200
> > +++ linux/include/linux/rmap.h	2009-06-03 19:36:23.000000000 +0200
> > @@ -93,6 +93,7 @@
> >  
> >  	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
> >  	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> > +	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
> 
> Or more precisely comment it as "corrupted data is recoverable"?

I think the original comment is clear enough, not changing that for now.

Thanks,
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
