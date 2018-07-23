Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64C096B000D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 16:33:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az8-v6so1155010plb.15
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 13:33:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ba4-v6sor773857plb.127.2018.07.23.13.33.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 13:33:22 -0700 (PDT)
Date: Mon, 23 Jul 2018 13:33:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3 -mm 3/6] mm, memcg: add hierarchical usage oom
 policy
In-Reply-To: <alpine.DEB.2.21.1807162101170.157949@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1807231331510.105582@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com> <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com> <alpine.DEB.2.20.1803221451370.17056@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807131604560.217600@chino.kir.corp.google.com> <alpine.DEB.2.21.1807131605590.217600@chino.kir.corp.google.com> <20180716181613.GA28327@castle> <alpine.DEB.2.21.1807162101170.157949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 16 Jul 2018, David Rientjes wrote:

> > And "tree" is different. It actually changes how the selection algorithm works,
> > and sub-tree settings do matter in this case.
> > 
> 
> "Tree" is considering the entity as a single indivisible memory consumer, 
> it is compared with siblings based on its hierarhical usage.  It has 
> cgroup oom policy.
> 
> It would be possible to separate this out, if you'd prefer, to account 
> an intermediate cgroup as the largest descendant or the sum of all 
> descendants.  I hadn't found a usecase for that, however, but it doesn't 
> mean there isn't one.  If you'd like, I can introduce another tunable.
> 

Roman, I'm trying to make progress so that the cgroup aware oom killer is 
in a state that it can be merged.  Would you prefer a second tunable here 
to specify a cgroup's points includes memory from its subtree?

It would be helpful if you would also review the rest of the patchset.
