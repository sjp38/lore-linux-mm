Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 65F8E6B0071
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 04:40:47 -0500 (EST)
Date: Thu, 2 Dec 2010 09:40:29 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch]vmscan: make kswapd use a correct order
Message-ID: <20101202094029.GP13268@csn.ul.ie>
References: <1291172911.12777.58.camel@sli10-conroe> <20101201132730.ABC2.A69D9226@jp.fujitsu.com> <20101201155854.GA3372@barrios-desktop> <20101201161954.aa90e957.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101201161954.aa90e957.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 01, 2010 at 04:19:54PM -0800, Andrew Morton wrote:
> 
> Paging Mel Gorman.  This fix looks pretty thoroughly related to your
> "[RFC PATCH 0/3] Prevent kswapd dumping excessive amounts of memory in
> response to high-order allocations"?
> 

It affects the same area and I'll need to rebase this patch on top of
my series for testing by Simon and his "aggressive kswapd" problem. I
haven't finished reviewing the thread yet but my initial impressions are
that it won't fix Simon's problem but that it's a real issue.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
