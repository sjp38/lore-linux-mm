Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2301B6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 21:49:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q21-v6so3947631pff.21
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 18:49:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6-v6sor3110453pgb.24.2018.07.30.18.49.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 18:49:33 -0700 (PDT)
Date: Mon, 30 Jul 2018 18:49:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
In-Reply-To: <20180730180100.25079-1-guro@fb.com>
Message-ID: <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
References: <20180730180100.25079-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, 30 Jul 2018, Roman Gushchin wrote:

> This is a tiny implementation of cgroup-aware OOM killer,
> which adds an ability to kill a cgroup as a single unit
> and so guarantee the integrity of the workload.
> 
> Although it has only a limited functionality in comparison
> to what now resides in the mm tree (it doesn't change
> the victim task selection algorithm, doesn't look
> at memory stas on cgroup level, etc), it's also much
> simpler and more straightforward. So, hopefully, we can
> avoid having long debates here, as we had with the full
> implementation.
> 
> As it doesn't prevent any futher development,
> and implements an useful and complete feature,
> it looks as a sane way forward.
> 
> This patchset is against Linus's tree to avoid conflicts
> with the cgroup-aware OOM killer patchset in the mm tree.
> 
> Two first patches are already in the mm tree.
> The first one ("mm: introduce mem_cgroup_put() helper")
> is totally fine, and the second's commit message has to be
> changed to reflect that it's not a part of old patchset
> anymore.
> 

What's the plan with the cgroup aware oom killer?  It has been sitting in 
the -mm tree for ages with no clear path to being merged.

Are you suggesting this patchset as a preliminary series so the cgroup 
aware oom killer should be removed from the -mm tree and this should be 
merged instead?  If so, what is the plan going forward for the cgroup 
aware oom killer?

Are you planning on reviewing the patchset to fix the cgroup aware oom 
killer at https://marc.info/?l=linux-kernel&m=153152325411865 which has 
been waiting for feedback since March?
