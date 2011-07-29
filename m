Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2EA716B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 20:17:37 -0400 (EDT)
Subject: Re: [patch 3/3]vmscan: cleanup kswapd_try_to_sleep
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110728110304.GL3010@suse.de>
References: <1311840789.15392.409.camel@sli10-conroe>
	 <20110728110304.GL3010@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Jul 2011 08:17:23 +0800
Message-ID: <1311898643.15392.410.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 2011-07-28 at 19:03 +0800, Mel Gorman wrote:
> On Thu, Jul 28, 2011 at 04:13:09PM +0800, Shaohua Li wrote:
> > cleanup kswapd_try_to_sleep() a little bit. Sometimes kswapd doesn't
> > really sleep. In such case, don't call prepare_to_wait/finish_wait.
> > It just wastes CPU.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> Out of curiousity, under what circumstances is the CPU usage
> noticeable? The patch itself seems fine so;
no, as the title says, this is a cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
