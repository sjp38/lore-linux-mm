Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 42D106B02B6
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 07:10:23 -0400 (EDT)
Date: Wed, 4 Aug 2010 12:10:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Why PAGEOUT_IO_SYNC stalls for a long time
Message-ID: <20100804111005.GA17745@csn.ul.ie>
References: <20100730115222.4AD8.A69D9226@jp.fujitsu.com> <20100730103018.GE3571@csn.ul.ie> <20100801174229.4B08.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100801174229.4B08.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 01, 2010 at 05:47:08PM +0900, KOSAKI Motohiro wrote:
> > > side note: page lock contention is very common case.
> > > 
> > > For case (8), I don't think sleeping is right way. get_page() is used in really various place of
> > > our kernel. so we can't assume it's only temporary reference count increasing.
> > 
> > In what case is a munlocked pages reference count permanently increased and
> > why is this not a memory leak?
> 
> V4L, audio, GEM and/or other multimedia driver?
> 

Ok, that is quite likely. Have you made a start on a series related to
lumpy reclaim? I was holding off making a start on such a thing while I
reviewed the other writeback issues and travelling to MM Summit is going
to delay things for me. If you haven't started when I get back, I'll
make some sort of stab at it.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
