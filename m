Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 879CD6B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 23:25:30 -0400 (EDT)
Date: Thu, 9 Sep 2010 11:25:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 05/10] vmscan: Synchrounous lumpy reclaim use
 lock_page() instead trylock_page()
Message-ID: <20100909032524.GA12245@localhost>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
 <1283770053-18833-6-git-send-email-mel@csn.ul.ie>
 <20100909120448.58acc9a6.kamezawa.hiroyu@jp.fujitsu.com>
 <20100909121547.2e69735a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100909121547.2e69735a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 09, 2010 at 11:15:47AM +0800, KAMEZAWA Hiroyuki wrote:
> On Thu, 9 Sep 2010 12:04:48 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon,  6 Sep 2010 11:47:28 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > 
> > > With synchrounous lumpy reclaim, there is no reason to give up to reclaim
> > > pages even if page is locked. This patch uses lock_page() instead of
> > > trylock_page() in this case.
> > > 
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> Ah......but can't this change cause dead lock ??

You mean the task goes for page allocation while holding some page
lock? Seems possible.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
