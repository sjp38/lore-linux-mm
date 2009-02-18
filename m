Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CB6C46B0082
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 05:23:58 -0500 (EST)
Date: Wed, 18 Feb 2009 11:26:03 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] vmscan: respect higher order in zone_reclaim()
Message-ID: <20090218102603.GA2160@cmpxchg.org>
References: <20090217194826.GA17415@cmpxchg.org> <20090218101204.GA27970@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090218101204.GA27970@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 18, 2009 at 10:12:04AM +0000, Mel Gorman wrote:
> On Tue, Feb 17, 2009 at 08:48:27PM +0100, Johannes Weiner wrote:
> > zone_reclaim() already tries to free the requested 2^order pages but
> > doesn't pass the order information into the inner reclaim code.
> > 
> > This prevents lumpy reclaim from happening on higher orders although
> > the caller explicitely asked for that.
> > 
> > Fix it up by initializing the order field of the scan control
> > according to the request.
> > 
> 
> I'm fine with the patch but the changelog could have been better.  Optionally
> take this changelog but either way.
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
> Optional alternative changelog
> ==============================
> 
> During page allocation, there are two stages of direct reclaim that are applied
> to each zone in the preferred list. The first stage using zone_reclaim()
> reclaims unmapped file backed pages and slab pages if over defined limits as
> these are cheaper to reclaim. The caller specifies the order of the target
> allocation but the scan control is not being correctly initialised.
> 
> The impact is that the correct number of pages are being reclaimed but that
> lumpy reclaim is not being applied. This increases the chances of a full
> direct reclaim via try_to_free_pages() is required.
> 
> This patch initialises the order field of the scan control as requested
> by the caller.

Agreed, this is better.  Thank you, Mel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
