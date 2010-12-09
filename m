Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B525D6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 17:14:52 -0500 (EST)
Date: Thu, 9 Dec 2010 14:13:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: make kswapd use a correct order
Message-Id: <20101209141317.60d14fb5.akpm@linux-foundation.org>
In-Reply-To: <1291305649-2405-1-git-send-email-minchan.kim@gmail.com>
References: <1291305649-2405-1-git-send-email-minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri,  3 Dec 2010 01:00:49 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> +static bool kswapd_try_to_sleep(pg_data_t *pgdat, int order)

OT: kswapd_try_to_sleep() does a
trace_mm_vmscan_kswapd_sleep(pgdat->node_id) if it sleeps for a long
time, but doesn't trace anything at all if it does a short sleep. 
Where's the sense in that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
