Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 64C646B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:06:36 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0916XKb005606
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Jan 2009 10:06:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A77EF45DE4E
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 10:06:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8657D45DE4C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 10:06:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F0E11DB803F
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 10:06:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CF871DB803C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 10:06:33 +0900 (JST)
Date: Fri, 9 Jan 2009 10:05:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] memcg: fix for
 mem_cgroup_get_reclaim_stat_from_page
Message-Id: <20090109100531.03cd998f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4966A117.9030201@cn.fujitsu.com>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
	<4966A117.9030201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 09 Jan 2009 08:57:59 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e2996b8..62e69d8 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -559,6 +559,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
> >  		return NULL;
> >  
> >  	pc = lookup_page_cgroup(page);
> > +	smp_rmb();
> 
> It is better to add a comment to explain this smp_rmb. I think it's recommended
> that every memory barrier has a comment.
> 
Ah, yes. good point.

Maybe text like this
/*
 * Used bit is set without atomic ops but after smp_wmb().
 * For making pc->mem_cgroup visible, insert smp_rmb() here.
 */

?
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
