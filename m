Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 656936B00C4
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:37:07 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K2b0IL010289
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Oct 2010 11:37:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ABA145DE51
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:37:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60B2F45DE4D
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:37:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C2CCE18001
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:37:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD0EBE08006
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:36:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/2] mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <alpine.DEB.2.00.1010191208130.15499@chino.kir.corp.google.com>
References: <20101019140955.A1EE.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010191208130.15499@chino.kir.corp.google.com>
Message-Id: <20101020113613.181E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Oct 2010 11:36:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 19 Oct 2010, KOSAKI Motohiro wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 14ee899..222d8cc 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -51,6 +51,7 @@
> >  #include <linux/kmemleak.h>
> >  #include <linux/memory.h>
> >  #include <linux/compaction.h>
> > +#include <linux/vmstat.h>
> >  #include <trace/events/kmem.h>
> >  #include <linux/ftrace_event.h>
> >  
> > @@ -5013,6 +5014,8 @@ int __meminit init_per_zone_wmark_min(void)
> >  		min_free_kbytes = 128;
> >  	if (min_free_kbytes > 65536)
> >  		min_free_kbytes = 65536;
> > +
> > +	refresh_zone_stat_thresholds();
> >  	setup_per_zone_wmarks();
> >  	setup_per_zone_lowmem_reserve();
> >  	setup_per_zone_inactive_ratio();
> 
> setup_per_zone_wmarks() could change the min and low watermarks for a zone 
> when refresh_zone_stat_thresholds() would have used the old value.

Good catch. thanks.

my previous version removed zone->percpu_drift_mark completely. but
current one doesn't. so I need to fix this.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
