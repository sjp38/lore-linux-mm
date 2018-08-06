Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92EF36B0008
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 14:19:30 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id l7-v6so11644878ybq.3
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 11:19:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3-v6sor428043ywe.436.2018.08.06.11.19.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 11:19:29 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:19:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180806181926.GF410235@devbig004.ftw2.facebook.com>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180806161529.GA410235@devbig004.ftw2.facebook.com>
 <20180806110845.f2cc110df0341b8cbd54d16c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806110845.f2cc110df0341b8cbd54d16c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon, Aug 06, 2018 at 11:08:45AM -0700, Andrew Morton wrote:
> On Mon, 6 Aug 2018 09:15:29 -0700 Tejun Heo <tj@kernel.org> wrote:
> 
> > mem_cgroup_print_oom_info() currently prints the same info for cgroup1
> > and cgroup2 OOMs.  It doesn't make much sense on cgroup2, which
> > doesn't use memsw or separate kmem accounting - the information
> > reported is both superflous and insufficient.  This patch updates the
> > memcg OOM messages on cgroup2 so that
> > 
> > * It prints memory and swap usages and limits used on cgroup2.
> > 
> > * It shows the same information as memory.stat.
> > 
> > I took out the recursive printing for cgroup2 because the amount of
> > output could be a lot and the benefits aren't clear.  An example dump
> > follows.
> 
> This conflicts rather severely with Shakeel's "memcg: reduce memcg tree
> traversals for stats collection".  Can we please park this until after
> 4.19-rc1?

Sure, or I can refresh the patch on top of -mm too.

Thanks.

-- 
tejun
