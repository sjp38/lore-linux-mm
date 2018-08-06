Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 261DA6B0269
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:45:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d18-v6so10842056qtj.20
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:45:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3-v6sor6304359qta.84.2018.08.06.08.45.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:45:17 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:48:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180806154815.GA14519@cmpxchg.org>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 03, 2018 at 10:57:43AM -0700, Tejun Heo wrote:
> mem_cgroup_print_oom_info() currently prints the same info for cgroup1
> and cgroup2 OOMs.  It doesn't make much sense on cgroup2, which
> doesn't use memsw or separate kmem accounting - the information
> reported is both superflous and insufficient.  This patch updates the
> memcg OOM messages on cgroup2 so that
> 
> * It prints memory and swap usages and limits used on cgroup2.
> 
> * It shows the same information as memory.stat.

That does look a lot more useful to me than the stuff we print now.

> I took out the recursive printing for cgroup2 because the amount of
> output could be a lot and the benefits aren't clear.

Agreed.

> What do you guys think?
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
