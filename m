Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7D556B0322
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 18:03:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 6so1603199pgh.0
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 15:03:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r20sor349253pfl.68.2017.09.07.15.03.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 15:03:27 -0700 (PDT)
Date: Thu, 7 Sep 2017 15:03:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
In-Reply-To: <alpine.DEB.2.20.1709071122360.20082@nuc-kabylake>
Message-ID: <alpine.DEB.2.10.1709071502430.143767@chino.kir.corp.google.com>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com> <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905215344.GA27427@cmpxchg.org> <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
 <alpine.DEB.2.20.1709071122360.20082@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 7 Sep 2017, Christopher Lameter wrote:

> > I am not sure this is how things evolved actually. This is way before
> > my time so my git log interpretation might be imprecise. We do have
> > oom_badness heuristic since out_of_memory has been introduced and
> > oom_kill_allocating_task has been introduced much later because of large
> > boxes with zillions of tasks (SGI I suspect) which took too long to
> > select a victim so David has added this heuristic.
> 
> Nope. The logic was required for tasks that run out of memory when the
> restriction on the allocation did not allow the use of all of memory.
> cpuset restrictions and memory policy restrictions where the prime
> considerations at the time.
> 
> It has *nothing* to do with zillions of tasks. Its amusing that the SGI
> ghost is still haunting the discussion here. The company died a couple of
> years ago finally (ok somehow HP has an "SGI" brand now I believe). But
> there are multiple companies that have large NUMA configurations and they
> all have configurations where they want to restrict allocations of a
> process to subset of system memory. This is even more important now that
> we get new forms of memory (NVDIMM, PCI-E device memory etc). You need to
> figure out what to do with allocations that fail because the *allowed*
> memory pools are empty.
> 

We already had CONSTRAINT_CPUSET at the time, this was requested by Paul 
and acked by him in https://marc.info/?l=linux-mm&m=118306851418425.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
