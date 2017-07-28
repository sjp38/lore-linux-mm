Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0EA6B054D
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:34:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d24so112866wmi.0
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:34:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si3586682wmd.49.2017.07.28.06.34.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 06:34:23 -0700 (PDT)
Date: Fri, 28 Jul 2017 15:34:22 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [4.13-rc1] /proc/meminfo reports that Slab: is little used.
Message-ID: <20170728133421.GR2274@dhcp22.suse.cz>
References: <201707260628.v6Q6SmaS030814@www262.sakura.ne.jp>
 <20170727162355.GA23896@cmpxchg.org>
 <20170728090750.GH2274@dhcp22.suse.cz>
 <20170728130517.GA16849@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728130517.GA16849@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Josef Bacik <josef@toxicpanda.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Fri 28-07-17 09:05:17, Johannes Weiner wrote:
> On Fri, Jul 28, 2017 at 11:07:51AM +0200, Michal Hocko wrote:
[...]
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Fri, 28 Jul 2017 11:02:51 +0200
> > Subject: [PATCH] mm: rename global_page_state to global_zone_page_state
> > 
> > global_page_state is error prone as a recent bug report pointed out [1].
> > It only returns proper values for zone based counters as the enum it
> > gets suggests. We already have global_node_page_state so let's rename
> > global_page_state to global_zone_page_state to be more explicit here.
> > All existing users seems to be correct
> > $ git grep "global_page_state(NR_" | sed 's@.*(\(NR_[A-Z_]*\)).*@\1@' | sort | uniq -c
> >       2 NR_BOUNCE
> >       2 NR_FREE_CMA_PAGES
> >      11 NR_FREE_PAGES
> >       1 NR_KERNEL_STACK_KB
> >       1 NR_MLOCK
> >       2 NR_PAGETABLE
> > 
> > This patch shouldn't introduce any functional change.
> > 
> > [1] http://lkml.kernel.org/r/201707260628.v6Q6SmaS030814@www262.sakura.ne.jp
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Yeah I think that's a good idea. I suspect Mel wanted to keep churn in
> unrelated callsites down when he introduced the node stuff, since that
> was already a big patch series. It makes sense to clean this up now.

yeah that would make sense.

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks! Could you post both patches when sending to Andrew, please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
