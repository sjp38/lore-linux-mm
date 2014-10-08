Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B015E6B007B
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 08:48:29 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id cc10so12142851wib.0
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 05:48:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h5si720830wiy.3.2014.10.08.05.48.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 05:48:28 -0700 (PDT)
Date: Wed, 8 Oct 2014 14:48:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/3] mm: memcontrol: eliminate charge reparenting
Message-ID: <20141008124823.GA4592@dhcp22.suse.cz>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat 20-09-14 16:00:32, Johannes Weiner wrote:
> Hi,
> 
> we've come a looong way when it comes to the basic cgroups model, and
> the recent changes there open up a lot of opportunity to make drastic
> simplifications to memory cgroups as well.
> 
> The decoupling of css from the user-visible cgroup, word-sized per-cpu
> css reference counters, and css iterators that include offlined groups
> means we can take per-charge css references, continue to reclaim from
> offlined groups, and so get rid of the error-prone charge reparenting.
> 
> Combined with the higher-order reclaim fixes, lockless page counters,
> and memcg iterator simplification I sent on Friday, the memory cgroup
> core code is finally no longer the biggest file in mm/.  Yay!

Yeah, the code reduction (as per the diffstat - I didn't get to the code
yet) seems really promising.

> These patches are based on mmotm + the above-mentioned changes

> + Tj's percpu-refcount conversion to atomic_long_t.

This is https://lkml.org/lkml/2014/9/20/11 right?

> Thanks!
> 
>  include/linux/cgroup.h          |  26 +++
>  include/linux/percpu-refcount.h |  43 ++++-
>  mm/memcontrol.c                 | 337 ++------------------------------------
>  3 files changed, 75 insertions(+), 331 deletions(-)
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
