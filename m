Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D96FD6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 21:38:26 -0500 (EST)
Date: Fri, 9 Jan 2009 11:34:58 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/4] memcg: fix for
 mem_cgroup_get_reclaim_stat_from_page
Message-Id: <20090109113458.d9a1320d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090109100531.03cd998f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
	<4966A117.9030201@cn.fujitsu.com>
	<20090109100531.03cd998f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 10:05:31 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 09 Jan 2009 08:57:59 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index e2996b8..62e69d8 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -559,6 +559,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
> > >  		return NULL;
> > >  
> > >  	pc = lookup_page_cgroup(page);
> > > +	smp_rmb();
> > 
> > It is better to add a comment to explain this smp_rmb. I think it's recommended
> > that every memory barrier has a comment.
> > 
> Ah, yes. good point.
> 
> Maybe text like this
> /*
>  * Used bit is set without atomic ops but after smp_wmb().
>  * For making pc->mem_cgroup visible, insert smp_rmb() here.
>  */
> 
OK. I'll add this comment.

BTW, mem_cgroup_rotate_lru_list and mem_cgroup_add_lru_list have similar code.
(mem_cgroup_add_lru_list has some comment already.)
Should I update them too ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
