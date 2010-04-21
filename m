Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 011206B01F4
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:14:40 -0400 (EDT)
Date: Wed, 21 Apr 2010 16:14:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100421151417.GK30306@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1004210927550.4959@router.home> <20100421150037.GJ30306@csn.ul.ie> <alpine.DEB.2.00.1004211004360.4959@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004211004360.4959@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 10:05:21AM -0500, Christoph Lameter wrote:
> On Wed, 21 Apr 2010, Mel Gorman wrote:
> 
> > No, remap_swapcache could just be called "remap". If it's 0, it's
> > considered unsafe to remap the page.
> 
> Call this "can_remap"?
> 

can_do - ba dum tisch.

While you are looking though, maybe you can confirm something for me.

1. Is leaving a migration PTE like this behind reasonable? (I think yes
   particularly as the page was already unmapped so it's not a new fault
   incurred)
2. Is the BUG_ON check in
   include/linux/swapops.h#migration_entry_to_page() now wrong? (I
   think yes, but I'm not sure and I'm having trouble verifying it)

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
