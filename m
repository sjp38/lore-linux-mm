Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9O4baJb021477
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 24 Oct 2008 13:37:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 003372AC025
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:37:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C718B12C049
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:37:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B151F1DB803F
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:37:35 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 668BA1DB803A
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:37:35 +0900 (JST)
Date: Fri, 24 Oct 2008 13:37:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/11] memcg: account move and change force_empty
Message-Id: <20081024133706.a9cee2a4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081023212837.960db1e8.randy.dunlap@oracle.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023180538.6fc7ee69.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023212837.960db1e8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008 21:28:37 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Thu, 23 Oct 2008 18:05:38 +0900 KAMEZAWA Hiroyuki wrote:
> 
> >  Documentation/controllers/memory.txt |   12 -
> >  mm/memcontrol.c                      |  277 ++++++++++++++++++++++++++---------
> >  2 files changed, 214 insertions(+), 75 deletions(-)
> > 
> > Index: mmotm-2.6.27+/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.27+.orig/mm/memcontrol.c
> > +++ mmotm-2.6.27+/mm/memcontrol.c
> > @@ -538,6 +533,25 @@ nomem:
> >  	return -ENOMEM;
> >  }
> >  
> > +/**
> > + * mem_cgroup_try_charge - get charge of PAGE_SIZE.
> > + * @mm: an mm_struct which is charged against. (when *memcg is NULL)
> > + * @gfp_mask: gfp_mask for reclaim.
> > + * @memcg: a pointer to memory cgroup which is charged against.
> > + *
> > + * charge aginst memory cgroup pointed by *memcg. if *memcg == NULL, estimated
> > + * memory cgroup from @mm is got and stored in *memcg.
> > + *
> > + * Retruns 0 if success. -ENOMEM at failure.
> 
>       Returns
> 
> > + * This call can invoce OOM-Killer.
> 
>                     invoke
> 

Thanks, will fix. (and use aspell before next post..)

Regards,
-kame

> > + */
> 
> ---
> ~Randy
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
