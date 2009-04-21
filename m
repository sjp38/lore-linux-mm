Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 526386B006A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 04:51:44 -0400 (EDT)
Date: Tue, 21 Apr 2009 09:52:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 24/25] Re-sort GFP flags and fix whitespace alignment
	for easier reading.
Message-ID: <20090421085229.GH12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-25-git-send-email-mel@csn.ul.ie> <1240301043.771.56.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240301043.771.56.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 11:04:03AM +0300, Pekka Enberg wrote:
> On Mon, 2009-04-20 at 23:20 +0100, Mel Gorman wrote:
> > Resort the GFP flags after __GFP_MOVABLE got redefined so how the bits
> > are used are a bit cleared.
> 
> I'm confused. AFAICT, this patch just fixes up some whitespace issues
> but doesn't actually "sort" anything?
> 

Hmm, doh. This resorted when another patch existed that no longer exists
due to difficulties. This patch only fixes whitespace now but I didn't fix
the changelog.  I can either move it to the next set altogether where it
does resort things or drop it on the grounds whitespace patches just muck
with changelogs. I'm leaning towards the latter.

> > 
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> The "From" tag should be the first line of the patch.
> 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/gfp.h |    8 ++++----
> >  1 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index c7429b8..cfc1dd3 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -47,11 +47,11 @@ struct vm_area_struct;
> >  #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* See above */
> >  #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
> >  #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
> > -#define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
> > -#define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
> > -#define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
> > +#define __GFP_NOMEMALLOC  ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
> > +#define __GFP_HARDWALL    ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
> > +#define __GFP_THISNODE	  ((__force gfp_t)0x40000u) /* No fallback, no policies */
> >  #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
> > -#define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
> > +#define __GFP_MOVABLE	  ((__force gfp_t)0x100000u)/* Page is movable */
> >  
> >  #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
> >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
