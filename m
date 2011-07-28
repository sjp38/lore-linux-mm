Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 689146B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 07:03:10 -0400 (EDT)
Date: Thu, 28 Jul 2011 12:03:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 3/3]vmscan: cleanup kswapd_try_to_sleep
Message-ID: <20110728110304.GL3010@suse.de>
References: <1311840789.15392.409.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311840789.15392.409.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 28, 2011 at 04:13:09PM +0800, Shaohua Li wrote:
> cleanup kswapd_try_to_sleep() a little bit. Sometimes kswapd doesn't
> really sleep. In such case, don't call prepare_to_wait/finish_wait.
> It just wastes CPU.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Out of curiousity, under what circumstances is the CPU usage
noticeable? The patch itself seems fine so;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
