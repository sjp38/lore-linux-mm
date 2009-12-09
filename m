Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3127160021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 19:31:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB90VbRr008140
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Dec 2009 09:31:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E48245DE55
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:31:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CA3A45DE4E
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:31:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDDCE1DB8042
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:31:36 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A52D11DB803A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:31:36 +0900 (JST)
Date: Wed, 9 Dec 2009 09:28:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: correct return value at mem_cgroup reclaim
Message-Id: <20091209092842.03a2b0dc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091206223046.4b08cbfb.d-nishimura@mtf.biglobe.ne.jp>
References: <COL115-W58F42F7BEEB67BF8324B2A9F910@phx.gbl>
	<20091206223046.4b08cbfb.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, Liu bo <bo-liu@hotmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Sun, 6 Dec 2009 22:30:46 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> hi,
> 
> On Sun, 6 Dec 2009 18:16:14 +0800
> Liu bo <bo-liu@hotmail.com> wrote:
> 
> > 
> > In order to indicate reclaim has succeeded, mem_cgroup_hierarchical_reclaim() used to return 1.
> > Now the return value is without indicating whether reclaim has successded usage, so just return the total reclaimed pages don't plus 1.
> >  
> > Signed-off-by: Liu Bo <bo-liu@hotmail.com>
> > ---
> >  
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 14593f5..51b6b3c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -737,7 +737,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >    css_put(&victim->css);
> >    total += ret;
> >    if (mem_cgroup_check_under_limit(root_mem))
> > -   return 1 + total;
> > +   return total;
> >   }
> >   return total;
> >  } 		 	   		  
> What's the benefit of this change ?
> I can't find any benefit to bother changing current behavior.
> 

please leave this as it is or adds comment.
This "1 + total" means "returning success, not 0" even if this has no behavior changes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
