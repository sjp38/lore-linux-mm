Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8DF06B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 11:51:56 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id b12-v6so8469208ybr.12
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:51:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f63-v6sor3335198ybb.106.2018.07.31.08.51.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 08:51:53 -0700 (PDT)
Date: Tue, 31 Jul 2018 11:54:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
Message-ID: <20180731155447.GA28424@cmpxchg.org>
References: <20180730180100.25079-1-guro@fb.com>
 <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Jul 30, 2018 at 06:49:31PM -0700, David Rientjes wrote:
> On Mon, 30 Jul 2018, Roman Gushchin wrote:
> 
> > This is a tiny implementation of cgroup-aware OOM killer,
> > which adds an ability to kill a cgroup as a single unit
> > and so guarantee the integrity of the workload.
> > 
> > Although it has only a limited functionality in comparison
> > to what now resides in the mm tree (it doesn't change
> > the victim task selection algorithm, doesn't look
> > at memory stas on cgroup level, etc), it's also much
> > simpler and more straightforward. So, hopefully, we can
> > avoid having long debates here, as we had with the full
> > implementation.
> > 
> > As it doesn't prevent any futher development,
> > and implements an useful and complete feature,
> > it looks as a sane way forward.
> > 
> > This patchset is against Linus's tree to avoid conflicts
> > with the cgroup-aware OOM killer patchset in the mm tree.
> > 
> > Two first patches are already in the mm tree.
> > The first one ("mm: introduce mem_cgroup_put() helper")
> > is totally fine, and the second's commit message has to be
> > changed to reflect that it's not a part of old patchset
> > anymore.
> 
> What's the plan with the cgroup aware oom killer?  It has been sitting in 
> the -mm tree for ages with no clear path to being merged.
> 
> Are you suggesting this patchset as a preliminary series so the cgroup 
> aware oom killer should be removed from the -mm tree and this should be 
> merged instead?  If so, what is the plan going forward for the cgroup 
> aware oom killer?
> 
> Are you planning on reviewing the patchset to fix the cgroup aware oom 
> killer at https://marc.info/?l=linux-kernel&m=153152325411865 which has 
> been waiting for feedback since March?

I would say it's been waiting for feedback since March because every
person that could give meaningful feedback on it, incl. the memcg and
cgroup maintainers, is happy with Roman's current patches in -mm, is
not convinced by the arguments you have made over months of
discussions, and has serious reservations about the configurable OOM
policies you propose as follow-up fix to Roman's patches.

This pared-down version of the patches proposed here is to accomodate
you and table discussions about policy for now. But your patchset is
highly unlikely to gain any sort of traction in the future.

Also I don't think there is any controversy here over what the way
forward should be. Roman's patches should have been merged months ago.
