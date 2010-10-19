Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5803F6B00AA
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 15:11:30 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o9JJBLMB026723
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:11:23 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by kpbe17.cbf.corp.google.com with ESMTP id o9JJB6U1014069
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:11:19 -0700
Received: by pzk1 with SMTP id 1so53080pzk.21
        for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:11:14 -0700 (PDT)
Date: Tue, 19 Oct 2010 12:11:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/2] mm, mem-hotplug: update pcp->stat_threshold
 when memory hotplug occur
In-Reply-To: <20101019140955.A1EE.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010191208130.15499@chino.kir.corp.google.com>
References: <20101019140831.A1EB.A69D9226@jp.fujitsu.com> <20101019140955.A1EE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010, KOSAKI Motohiro wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 14ee899..222d8cc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -51,6 +51,7 @@
>  #include <linux/kmemleak.h>
>  #include <linux/memory.h>
>  #include <linux/compaction.h>
> +#include <linux/vmstat.h>
>  #include <trace/events/kmem.h>
>  #include <linux/ftrace_event.h>
>  
> @@ -5013,6 +5014,8 @@ int __meminit init_per_zone_wmark_min(void)
>  		min_free_kbytes = 128;
>  	if (min_free_kbytes > 65536)
>  		min_free_kbytes = 65536;
> +
> +	refresh_zone_stat_thresholds();
>  	setup_per_zone_wmarks();
>  	setup_per_zone_lowmem_reserve();
>  	setup_per_zone_inactive_ratio();

setup_per_zone_wmarks() could change the min and low watermarks for a zone 
when refresh_zone_stat_thresholds() would have used the old value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
