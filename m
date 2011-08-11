Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5D46B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:25:21 -0400 (EDT)
Date: Thu, 11 Aug 2011 15:25:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix comment on update nodemask
Message-ID: <20110811132511.GM8023@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809190824.99347a0f.kamezawa.hiroyu@jp.fujitsu.com>
 <20110810100042.GA15007@tiehlicka.suse.cz>
 <20110811083043.a3b2ba65.kamezawa.hiroyu@jp.fujitsu.com>
 <20110811084456.5da61183.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110811084456.5da61183.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu 11-08-11 08:44:56, KAMEZAWA Hiroyuki wrote:
> 
> > > >  /*
> > > >   * Always updating the nodemask is not very good - even if we have an empty
> > > >   * list or the wrong list here, we can start from some node and traverse all
> > > > @@ -1575,7 +1593,6 @@ static bool test_mem_cgroup_node_reclaim
> > > >   */
> > > 
> > > Would be good to update the function comment as well (we still have 10s
> > > period there).
> > > 
> > 
> how about this ?
> ==
> 
> Update function's comment. The behavior is changed by commit 453a9bf3
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> Index: mmotm-Aug3/mm/memcontrol.c
> ===================================================================
> --- mmotm-Aug3.orig/mm/memcontrol.c
> +++ mmotm-Aug3/mm/memcontrol.c
> @@ -1568,10 +1568,7 @@ static bool test_mem_cgroup_node_reclaim
>  #if MAX_NUMNODES > 1
>  
>  /*
> - * Always updating the nodemask is not very good - even if we have an empty
> - * list or the wrong list here, we can start from some node and traverse all
> - * nodes based on the zonelist. So update the list loosely once per 10 secs.
> - *
> + * Update scan nodemask with memcg's event_counter(NUMAINFO_EVENTS_TARGET)
>   */
>  static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>  {

I would keep the first part about reasoning and just replace the one
about 10 secs update.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
