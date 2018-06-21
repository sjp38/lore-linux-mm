Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29DCE6B0006
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 11:05:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f7-v6so2592683wrq.19
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 08:05:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i43-v6si2645675ede.243.2018.06.21.08.05.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 08:05:42 -0700 (PDT)
Date: Thu, 21 Jun 2018 17:05:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180621150540.GO10465@dhcp22.suse.cz>
References: <20180620103736.13880-1-mhocko@kernel.org>
 <20180621080927.GE10465@dhcp22.suse.cz>
 <20180621143751.GA11230@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180621143751.GA11230@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 21-06-18 10:37:51, Johannes Weiner wrote:
> On Thu, Jun 21, 2018 at 10:09:27AM +0200, Michal Hocko wrote:
> > @@ -496,14 +496,14 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> >  
> >  static inline void mem_cgroup_oom_enable(void)
> >  {
> > -	WARN_ON(current->memcg_may_oom);
> > -	current->memcg_may_oom = 1;
> > +	WARN_ON(current->in_user_fault);
> > +	current->in_user_fault = 1;
> >  }
> >  
> >  static inline void mem_cgroup_oom_disable(void)
> >  {
> > -	WARN_ON(!current->memcg_may_oom);
> > -	current->memcg_may_oom = 0;
> > +	WARN_ON(!current->in_user_fault);
> > +	current->in_user_fault = 0;
> >  }
> 
> Would it make more sense to rename these to
> mem_cgroup_enter_user_fault(), mem_cgroup_exit_user_fault()?

OK, makes sense. It is less explicit about the oom behavior... 

> Other than that, this looks great to me.

Thanks for the review! I will wait few days for other feedback and
retest and repost then.
-- 
Michal Hocko
SUSE Labs
