Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 170DD6B01FC
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 05:38:41 -0400 (EDT)
Date: Fri, 27 Aug 2010 10:38:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Do not wait the full timeout on
	congestion_wait when there is no congestion
Message-ID: <20100827093825.GF19556@csn.ul.ie>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie> <20100826172038.GA6873@barrios-desktop> <20100827012147.GC7353@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100827012147.GC7353@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 09:21:47AM +0800, Wu Fengguang wrote:
> Minchan,
> 
> It's much cleaner to keep the unchanged congestion_wait() and add a
> congestion_wait_check() for converting problematic wait sites. The
> too_many_isolated() wait is merely a protective mechanism, I won't
> bother to improve it at the cost of more code.
> 

This is what I've done. I dropped the patch again and am using
wait_iff_congested(). I left the too_many_isolated() callers as
congestion_wait().

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
