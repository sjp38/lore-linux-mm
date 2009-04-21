Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EDFD46B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:43:17 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:43:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12/25] Remove a branch by assuming __GFP_HIGH ==
	ALLOC_HIGH
Message-ID: <20090421104354.GS12713@csn.ul.ie>
References: <1240266011-11140-13-git-send-email-mel@csn.ul.ie> <20090421180757.F145.A69D9226@jp.fujitsu.com> <20090421193030.F16B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421193030.F16B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 07:31:23PM +0900, KOSAKI Motohiro wrote:
> > > @@ -1639,8 +1639,8 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > >  	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> > >  	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
> > >  	 */
> > > -	if (gfp_mask & __GFP_HIGH)
> > > -		alloc_flags |= ALLOC_HIGH;
> > > +	VM_BUG_ON(__GFP_HIGH != ALLOC_HIGH);
> 
> Oops, I forgot said one comment.
> BUILD_BUG_ON() is better?
> 

Much better. Thanks

> 
> > > +	alloc_flags |= (gfp_mask & __GFP_HIGH);
> > >  
> > >  	if (!wait) {
> > >  		alloc_flags |= ALLOC_HARDER;
> > 
> > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > 
> > 
> 
> 
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
