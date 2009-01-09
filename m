Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 59EBD6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 21:43:01 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n092gwbv013480
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Jan 2009 11:42:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E72CD45DE51
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:42:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B717B45DE4E
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:42:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A095A1DB803F
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:42:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 445DD1DB803C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:42:57 +0900 (JST)
Date: Fri, 9 Jan 2009 11:41:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] memcg: fix for
 mem_cgroup_get_reclaim_stat_from_page
Message-Id: <20090109114155.75fd61fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090109113458.d9a1320d.nishimura@mxp.nes.nec.co.jp>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
	<4966A117.9030201@cn.fujitsu.com>
	<20090109100531.03cd998f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090109113458.d9a1320d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 11:34:58 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 9 Jan 2009 10:05:31 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 09 Jan 2009 08:57:59 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index e2996b8..62e69d8 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -559,6 +559,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
> > > >  		return NULL;
> > > >  
> > > >  	pc = lookup_page_cgroup(page);
> > > > +	smp_rmb();
> > > 
> > > It is better to add a comment to explain this smp_rmb. I think it's recommended
> > > that every memory barrier has a comment.
> > > 
> > Ah, yes. good point.
> > 
> > Maybe text like this
> > /*
> >  * Used bit is set without atomic ops but after smp_wmb().
> >  * For making pc->mem_cgroup visible, insert smp_rmb() here.
> >  */
> > 
> OK. I'll add this comment.
> 
> BTW, mem_cgroup_rotate_lru_list and mem_cgroup_add_lru_list have similar code.
> (mem_cgroup_add_lru_list has some comment already.)
> Should I update them too ?
> 
please :) it's helpful. Sorry for my too short comment on orignal patch.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
