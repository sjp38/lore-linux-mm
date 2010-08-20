Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 570D06B0339
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 10:55:01 -0400 (EDT)
Date: Fri, 20 Aug 2010 09:54:56 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] vmstat : update zone stat threshold at onlining a cpu
In-Reply-To: <20100820092251.2ca67f66.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008200954051.30700@router.home>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008181050230.4025@router.home> <20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008191359400.1839@router.home> <20100820084908.10e55b76.kamezawa.hiroyu@jp.fujitsu.com> <20100820092251.2ca67f66.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010, KAMEZAWA Hiroyuki wrote:

>  1 file changed, 1 insertion(+)
>
> Index: mmotm-0811/mm/vmstat.c
> ===================================================================
> --- mmotm-0811.orig/mm/vmstat.c
> +++ mmotm-0811/mm/vmstat.c
> @@ -998,6 +998,7 @@ static int __cpuinit vmstat_cpuup_callba
>  	switch (action) {
>  	case CPU_ONLINE:
>  	case CPU_ONLINE_FROZEN:
> +		refresh_zone_stat_thresholds();
>  		start_cpu_timer(cpu);
>  		node_set_state(cpu_to_node(cpu), N_CPU);
>  		break;

refresh_zone_stat_threshold must be run *after* the number of online cpus
has been incremented. Does that occur before the callback?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
