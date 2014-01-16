Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 20D4B6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 02:45:27 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id b12so850694yha.41
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 23:45:26 -0800 (PST)
Received: from mail-gg0-x232.google.com (mail-gg0-x232.google.com [2607:f8b0:4002:c02::232])
        by mx.google.com with ESMTPS id v3si8896167yhv.94.2014.01.15.23.45.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 23:45:26 -0800 (PST)
Received: by mail-gg0-f178.google.com with SMTP id q2so798258ggc.9
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 23:45:26 -0800 (PST)
Date: Wed, 15 Jan 2014 23:45:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: prefer thread group leaders for display
 purposes
In-Reply-To: <20140116070549.GL6963@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1401152344560.14407@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1401151837560.1835@chino.kir.corp.google.com> <20140116070549.GL6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 16 Jan 2014, Johannes Weiner wrote:

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index a815686..b482f49 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1841,13 +1841,17 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  				break;
> >  			};
> >  			points = oom_badness(task, memcg, NULL, totalpages);
> > -			if (points > chosen_points) {
> > -				if (chosen)
> > -					put_task_struct(chosen);
> > -				chosen = task;
> > -				chosen_points = points;
> > -				get_task_struct(chosen);
> 
> Where did that GET go?
> 

No idea, good catch!  This patch was doomed from the GET-go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
