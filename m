Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 13EAB900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 09:56:51 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so92389281wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 06:56:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si1355268wjr.166.2015.06.03.06.56.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 06:56:49 -0700 (PDT)
Date: Wed, 3 Jun 2015 15:56:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 1/2] memcg: remove unused mem_cgroup->oom_wakeups
Message-ID: <20150603135648.GF16201@dhcp22.suse.cz>
References: <20150603023824.GA7579@mtj.duckdns.org>
 <20150603134830.GD16201@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603134830.GD16201@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 03-06-15 15:48:30, Michal Hocko wrote:
> On Wed 03-06-15 11:38:24, Tejun Heo wrote:
> > From 92c2a5d90ecc5eeed0224a8f6ba533c621ac3ffa Mon Sep 17 00:00:00 2001
> > From: Tejun Heo <tj@kernel.org>
> > Date: Tue, 2 Jun 2015 09:29:11 -0400
> > 
> > Since 4942642080ea ("mm: memcg: handle non-error OOM situations more
> > gracefully"), nobody uses mem_cgroup->oom_wakeups.  Remove it.
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>

Could you also inline __wake_up from memcg_wakeup_oom into its only
caller while you are touching that code, please?

> 
> > ---
> >  mm/memcontrol.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 86648a7..9f39647 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -287,7 +287,6 @@ struct mem_cgroup {
> >  
> >  	bool		oom_lock;
> >  	atomic_t	under_oom;
> > -	atomic_t	oom_wakeups;
> >  
> >  	int	swappiness;
> >  	/* OOM-Killer disable */
> > @@ -1852,7 +1851,6 @@ static int memcg_oom_wake_function(wait_queue_t *wait,
> >  
> >  static void memcg_wakeup_oom(struct mem_cgroup *memcg)
> >  {
> > -	atomic_inc(&memcg->oom_wakeups);
> >  	/* for filtering, pass "memcg" as argument. */
> >  	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
> >  }
> > -- 
> > 2.4.2
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
