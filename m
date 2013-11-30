Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2C46B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 22:37:39 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so4595125bkh.3
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 19:37:38 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pb8si16060688bkb.51.2013.11.29.19.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 19:37:38 -0800 (PST)
Date: Fri, 29 Nov 2013 22:37:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131130033732.GM22729@cmpxchg.org>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org>
 <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
 <20131127233353.GH3556@cmpxchg.org>
 <20131128091255.GD2761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131128091255.GD2761@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 28, 2013 at 10:12:55AM +0100, Michal Hocko wrote:
> On Wed 27-11-13 18:33:53, Johannes Weiner wrote:
> [...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 13b9d0f..5f9e467 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2675,7 +2675,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		goto bypass;
> >  
> >  	if (unlikely(task_in_memcg_oom(current)))
> > -		goto bypass;
> > +		goto nomem;
> >  
> >  	/*
> >  	 * We always charge the cgroup the mm_struct belongs to.
> 
> Yes, I think we really want this. Plan to send a patch? The first charge
> failure due to OOM shouldn't be papered over by a later attempt if we
> didn't get through mem_cgroup_oom_synchronize yet.

Sure thing.  Will send this to Andrew on Monday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
