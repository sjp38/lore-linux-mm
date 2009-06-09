Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 16FF06B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:45:42 -0400 (EDT)
Date: Tue, 9 Jun 2009 20:21:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [6/16] HWPOISON: Add various poison checks in
	mm/memory.c
Message-ID: <20090609122131.GC5589@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184639.1933B1D028F@basil.firstfloor.org> <20090609102504.GH14820@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609102504.GH14820@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 06:25:04PM +0800, Nick Piggin wrote:
> On Wed, Jun 03, 2009 at 08:46:38PM +0200, Andi Kleen wrote:
> > 
> > Bail out early when hardware poisoned pages are found in page fault handling.
> > Since they are poisoned they should not be mapped freshly into processes,
> > because that would cause another (potentially deadly) machine check
> > 
> > This is generally handled in the same way as OOM, just a different
> > error code is returned to the architecture code.
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > 
> > ---
> >  mm/memory.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > Index: linux/mm/memory.c
> > ===================================================================
> > --- linux.orig/mm/memory.c	2009-06-03 19:36:23.000000000 +0200
> > +++ linux/mm/memory.c	2009-06-03 19:36:23.000000000 +0200
> > @@ -2797,6 +2797,9 @@
> >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> >  		return ret;
> >  
> > +	if (unlikely(PageHWPoison(vmf.page)))
> > +		return VM_FAULT_HWPOISON;
> 
> Again, it would be nice if you just worry about this in your MCE
> handler and don't sprinkle things like this in fastpaths.

For this patch, I cannot imagine a clear usage case for it, and
proposed to remove it until there comes a case.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
