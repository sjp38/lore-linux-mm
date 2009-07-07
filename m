Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C2D506B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:50:45 -0400 (EDT)
Date: Tue, 7 Jul 2009 21:51:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
Message-ID: <20090707135125.GA9444@localhost>
References: <20090707090120.1e71a060.minchan.kim@barrios-desktop> <20090707090509.0C60.A69D9226@jp.fujitsu.com> <20090707101855.0C63.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707101855.0C63.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 09:19:53AM +0800, KOSAKI Motohiro wrote:
> > > > Index: b/mm/vmscan.c
> > > > ===================================================================
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -1082,6 +1082,7 @@ static unsigned long shrink_inactive_lis
> > > >  						-count[LRU_ACTIVE_ANON]);
> > > >  		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
> > > >  						-count[LRU_INACTIVE_ANON]);
> > > > +		__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> > > 
> > > Lumpy can reclaim file + anon anywhere.  
> > > How about using count[NR_LRU_LISTS]?
> > 
> > Ah yes, good catch.
> 
> Fixed.
> 
> Subject: [PATCH] add isolate pages vmstat
> 
> If the system have plenty threads or processes, concurrent reclaim can
> isolate very much pages.
> Unfortunately, current /proc/meminfo and OOM log can't show it.
> 
> This patch provide the way of showing this information.

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

>  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> -		" inactive_file:%lu"
> -		" unevictable:%lu"
> +		" inactive_file:%lu unevictable:%lu\n"
> +		" isolated_anon:%lu isolated_file:%lu\n"

How about 
        active_anon inactive_anon isolated_anon
        active_file inactive_file isolated_file
?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
