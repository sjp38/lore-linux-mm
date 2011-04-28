Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CEAC86B0024
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:50:22 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A8E8B3EE0AE
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 22:50:19 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C9E345DE61
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 22:50:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 736AB45DE4D
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 22:50:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 65F7AE08001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 22:50:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3193A1DB803A
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 22:50:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] vmstat: account page allocation failures
In-Reply-To: <20110428133838.GA12573@localhost>
References: <20110428133644.GA12400@localhost> <20110428133838.GA12573@localhost>
Message-Id: <20110428225144.3D4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 28 Apr 2011 22:50:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

>  nopage:
> +	inc_zone_state(preferred_zone, NR_ALLOC_FAIL);
> +	/* count_zone_vm_events(PGALLOCFAIL, preferred_zone, 1 << order); */
>  	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
>  		unsigned int filter = SHOW_MEM_FILTER_NODES;
>  
> --- linux-next.orig/mm/vmstat.c	2011-04-28 21:34:30.000000000 +0800
> +++ linux-next/mm/vmstat.c	2011-04-28 21:34:35.000000000 +0800
> @@ -879,6 +879,7 @@ static const char * const vmstat_text[] 
>  	"nr_shmem",
>  	"nr_dirtied",
>  	"nr_written",
> +	"nr_alloc_fail",

I'm using very similar patch for debugging. However, this is useless for
admins because typical linux load have plenty GFP_ATOMIC allocation failure.
So, typical user have no way that failure rate is high or not.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
