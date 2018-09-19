Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B15B8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 13:17:52 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id v16-v6so2753684ybm.2
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 10:17:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 139-v6sor2403581ywx.246.2018.09.19.10.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 10:17:46 -0700 (PDT)
Date: Wed, 19 Sep 2018 13:17:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180919171744.GA18068@cmpxchg.org>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180806161529.GA410235@devbig004.ftw2.facebook.com>
 <20180806110845.f2cc110df0341b8cbd54d16c@linux-foundation.org>
 <20180806181926.GF410235@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806181926.GF410235@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon, Aug 06, 2018 at 11:19:26AM -0700, Tejun Heo wrote:
> On Mon, Aug 06, 2018 at 11:08:45AM -0700, Andrew Morton wrote:
> > On Mon, 6 Aug 2018 09:15:29 -0700 Tejun Heo <tj@kernel.org> wrote:
> > 
> > > mem_cgroup_print_oom_info() currently prints the same info for cgroup1
> > > and cgroup2 OOMs.  It doesn't make much sense on cgroup2, which
> > > doesn't use memsw or separate kmem accounting - the information
> > > reported is both superflous and insufficient.  This patch updates the
> > > memcg OOM messages on cgroup2 so that
> > > 
> > > * It prints memory and swap usages and limits used on cgroup2.
> > > 
> > > * It shows the same information as memory.stat.
> > > 
> > > I took out the recursive printing for cgroup2 because the amount of
> > > output could be a lot and the benefits aren't clear.  An example dump
> > > follows.
> > 
> > This conflicts rather severely with Shakeel's "memcg: reduce memcg tree
> > traversals for stats collection".  Can we please park this until after
> > 4.19-rc1?
> 
> Sure, or I can refresh the patch on top of -mm too.

Now that 4.19 is released, do you mind refreshing this for 4.20?
