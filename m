Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 157CA60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 01:22:37 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id nB96KpBR023135
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 17:20:51 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB96ImTR1188038
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 17:18:48 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB96MV1Z017603
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 17:22:32 +1100
Date: Wed, 9 Dec 2009 11:52:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: correct return value at mem_cgroup reclaim
Message-ID: <20091209062228.GD3722@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <COL115-W58F42F7BEEB67BF8324B2A9F910@phx.gbl>
 <20091206223046.4b08cbfb.d-nishimura@mtf.biglobe.ne.jp>
 <20091209092842.03a2b0dc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091209092842.03a2b0dc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, Liu bo <bo-liu@hotmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-12-09 09:28:42]:

> On Sun, 6 Dec 2009 22:30:46 +0900
> Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:
> 
> > hi,
> > 
> > On Sun, 6 Dec 2009 18:16:14 +0800
> > Liu bo <bo-liu@hotmail.com> wrote:
> > 
> > > 
> > > In order to indicate reclaim has succeeded, mem_cgroup_hierarchical_reclaim() used to return 1.
> > > Now the return value is without indicating whether reclaim has successded usage, so just return the total reclaimed pages don't plus 1.
> > >  
> > > Signed-off-by: Liu Bo <bo-liu@hotmail.com>
> > > ---
> > >  
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 14593f5..51b6b3c 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -737,7 +737,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > >    css_put(&victim->css);
> > >    total += ret;
> > >    if (mem_cgroup_check_under_limit(root_mem))
> > > -   return 1 + total;
> > > +   return total;
> > >   }
> > >   return total;
> > >  } 		 	   		  
> > What's the benefit of this change ?
> > I can't find any benefit to bother changing current behavior.
> > 
> 
> please leave this as it is or adds comment.
> This "1 + total" means "returning success, not 0" even if this has no behavior changes.
>

I prefer adding the comments, I will get to it if Liu does not.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
