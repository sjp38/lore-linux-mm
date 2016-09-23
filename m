Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3416B0279
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:15:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l132so11112345wmf.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:15:58 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id y77si2369509wme.72.2016.09.23.02.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 02:15:57 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b184so1737688wma.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:15:57 -0700 (PDT)
Date: Fri, 23 Sep 2016 11:15:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Message-ID: <20160923091555.GH4478@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <007901d21574$9ef82d60$dce88820$@alibaba-inc.com>
 <20160923083224.GF4478@dhcp22.suse.cz>
 <007a01d21576$b12ac4a0$13804de0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <007a01d21576$b12ac4a0$13804de0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>

On Fri 23-09-16 16:44:26, Hillf Danton wrote:
> On Friday, September 23, 2016 4:32 PM, Michal Hocko wrote
> > On Fri 23-09-16 16:29:36, Hillf Danton wrote:
> > [...]
> > > > @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  	else
> > > >  		no_progress_loops++;
> > > >
> > > > +	/* Make sure we know about allocations which stall for too long */
> > > > +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> > > > +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> > > > +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> > >
> > > Better if pid is also printed.
> > 
> > I've tried to be consistent with warn_alloc_failed and that doesn't
> > print pid either. Maybe both of them should. Dunno
> > 
> With pid imho we can distinguish two tasks with same name in a simpler way. 

I've just checked dump_stack and dump_stack_print_info provides that
information already.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
