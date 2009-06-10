Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BBDE46B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 06:35:19 -0400 (EDT)
Date: Wed, 10 Jun 2009 11:36:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/4] Count the number of times zone_reclaim() scans and
	fails
Message-ID: <20090610103622.GI25943@csn.ul.ie>
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie> <1244566904-31470-4-git-send-email-mel@csn.ul.ie> <20090610104635.DDA6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090610104635.DDA6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 10:47:20AM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> I like this patch. thank you mel.
> 
> > @@ -2489,6 +2489,10 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  	ret = __zone_reclaim(zone, gfp_mask, order);
> >  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
> >  
> > +	if (!ret) {
> > +		count_vm_events(PGSCAN_ZONERECLAIM_FAILED, 1);
> > +	}
> > +
> >  	return ret;
> 
> count_vm_event(PGSCAN_ZONERECLAIM_FAILED)?
> 

/me slaps self

Yes, that makes more sense.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
