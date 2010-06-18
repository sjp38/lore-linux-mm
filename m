Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A885F6B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 22:22:03 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5I2LxhO024933
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Jun 2010 11:21:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8011545DE50
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 11:21:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6657745DE4F
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 11:21:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 49463E08001
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 11:21:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 08B5F1DB8014
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 11:21:59 +0900 (JST)
Date: Fri, 18 Jun 2010 11:17:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH -mm] fix bad call of memcg_oom_recover at cancel
 move.
Message-Id: <20100618111735.b3d64d95.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100618105741.4e596ea7.nishimura@mxp.nes.nec.co.jp>
References: <20100617172034.00ea8835.kamezawa.hiroyu@jp.fujitsu.com>
	<20100617092442.GJ4306@balbir.in.ibm.com>
	<20100618105741.4e596ea7.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jun 2010 10:57:41 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > May I recommend the following change instead
> > 
> > 
> > Don't crash on a null memcg being passed, check if memcg
> > is NULL and handle the condition gracefully
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> >  mm/memcontrol.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c6ece0a..d71c488 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1370,7 +1370,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
> >  
> >  static void memcg_oom_recover(struct mem_cgroup *mem)
> >  {
> > -	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
> > +	if (mem && mem->oom_kill_disable && atomic_read(&mem->oom_lock))
> >  		memcg_wakeup_oom(mem);
> >  }
> >  
> I agree to this fix.
> 
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 

I tend to dislike band-aid in callee. but it's not important here.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
