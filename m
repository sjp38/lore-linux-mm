Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 437F26B0330
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:27:32 -0400 (EDT)
Date: Fri, 20 Aug 2010 10:29:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmstat : update zone stat threshold at onlining a cpu
Message-Id: <20100820102925.540a0b24.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1008200954051.30700@router.home>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-3-git-send-email-mel@csn.ul.ie>
	<20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008181050230.4025@router.home>
	<20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008191359400.1839@router.home>
	<20100820084908.10e55b76.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820092251.2ca67f66.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008200954051.30700@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 09:54:56 -0500 (CDT) Christoph Lameter <cl@linux-foundation.org> wrote:

> On Fri, 20 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> >  1 file changed, 1 insertion(+)
> >
> > Index: mmotm-0811/mm/vmstat.c
> > ===================================================================
> > --- mmotm-0811.orig/mm/vmstat.c
> > +++ mmotm-0811/mm/vmstat.c
> > @@ -998,6 +998,7 @@ static int __cpuinit vmstat_cpuup_callba
> >  	switch (action) {
> >  	case CPU_ONLINE:
> >  	case CPU_ONLINE_FROZEN:
> > +		refresh_zone_stat_thresholds();
> >  		start_cpu_timer(cpu);
> >  		node_set_state(cpu_to_node(cpu), N_CPU);
> >  		break;
> 
> refresh_zone_stat_threshold must be run *after* the number of online cpus
> has been incremented. Does that occur before the callback?

It does. _cpu_up() calls __cpu_up() before calling cpu_notify().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
