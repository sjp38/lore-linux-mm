Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E29956B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 17:18:56 -0500 (EST)
Date: Mon, 7 Nov 2011 23:18:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: do not kill tasks with oom_score_adj
 OOM_SCORE_ADJ_MIN
Message-ID: <20111107221847.GA7985@tiehlicka.suse.cz>
References: <20111104143145.0F93B8B45E@mx2.suse.de>
 <alpine.DEB.2.00.1111071353140.27419@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111071353140.27419@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon 07-11-11 13:54:38, David Rientjes wrote:
> On Fri, 4 Nov 2011, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index e916168..4883514 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -185,6 +185,9 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> >  	if (!p)
> >  		return 0;
> >  
> > +	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +		return 0;
> > +
> >  	/*
> >  	 * The memory controller may have a limit of 0 bytes, so avoid a divide
> >  	 * by zero, if necessary.
> 
> This leaves p locked, you need to do task_unlock(p) first.

Yes, right you are. Thanks for spotting this out.

> 
> Once that's fixed, please add my
> 
> 	Acked-by: David Rientjes <rientjes@google.com>

Thanks.

> and resubmit to Andrew for the 3.2 rc series.  Thanks!

Andrew, could you push this for 3.2 (bugfix for post 3.1 kernel).

---
