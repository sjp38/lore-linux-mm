Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5580A90001C
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 10:18:02 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id d1so10825250wiv.0
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 07:18:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id db5si259627wjb.19.2014.10.08.07.18.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Oct 2014 07:18:01 -0700 (PDT)
Date: Wed, 8 Oct 2014 10:17:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/3] mm: memcontrol: eliminate charge reparenting
Message-ID: <20141008141754.GD15948@cmpxchg.org>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
 <20141008124823.GA4592@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008124823.GA4592@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 08, 2014 at 02:48:23PM +0200, Michal Hocko wrote:
> On Sat 20-09-14 16:00:32, Johannes Weiner wrote:
> > Hi,
> > 
> > we've come a looong way when it comes to the basic cgroups model, and
> > the recent changes there open up a lot of opportunity to make drastic
> > simplifications to memory cgroups as well.
> > 
> > The decoupling of css from the user-visible cgroup, word-sized per-cpu
> > css reference counters, and css iterators that include offlined groups
> > means we can take per-charge css references, continue to reclaim from
> > offlined groups, and so get rid of the error-prone charge reparenting.
> > 
> > Combined with the higher-order reclaim fixes, lockless page counters,
> > and memcg iterator simplification I sent on Friday, the memory cgroup
> > core code is finally no longer the biggest file in mm/.  Yay!
> 
> Yeah, the code reduction (as per the diffstat - I didn't get to the code
> yet) seems really promising.

:)

> > These patches are based on mmotm + the above-mentioned changes
> 
> > + Tj's percpu-refcount conversion to atomic_long_t.
> 
> This is https://lkml.org/lkml/2014/9/20/11 right?

Yep, exactly.  All these moving parts are now in -next, though, so as
soon as Andrew flushes his tree for 3.18, I'll rebase and resubmit.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
