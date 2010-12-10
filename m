Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DEB06B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 06:17:56 -0500 (EST)
Date: Fri, 10 Dec 2010 11:17:37 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] vmscan: make kswapd use a correct order
Message-ID: <20101210111736.GO20133@csn.ul.ie>
References: <1291305649-2405-1-git-send-email-minchan.kim@gmail.com> <20101209141317.60d14fb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101209141317.60d14fb5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 02:13:17PM -0800, Andrew Morton wrote:
> On Fri,  3 Dec 2010 01:00:49 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > +static bool kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> 
> OT: kswapd_try_to_sleep() does a
> trace_mm_vmscan_kswapd_sleep(pgdat->node_id) if it sleeps for a long
> time, but doesn't trace anything at all if it does a short sleep. 
> Where's the sense in that?
> 

The tracepoint is to mark when kswapd is going fully to sleep and being
inactive because all its work is done. The tracepoints name might be
unfortunate because it's really used to track if kswapd is active or
inactive rather than sleeping.

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
