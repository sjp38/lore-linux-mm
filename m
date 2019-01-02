Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 136B18E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:18:34 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id l7so22828806ywh.16
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:18:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f124sor6985064ywe.27.2019.01.02.13.18.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 13:18:33 -0800 (PST)
MIME-Version: 1.0
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com> <1546459533-36247-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546459533-36247-2-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 2 Jan 2019 13:18:21 -0800
Message-ID: <CALvZod4yYJ7SNrEnpUFwMmaUaaaLgGFr199nqra41vidCPsB1w@mail.gmail.com>
Subject: Re: [PATCH 1/3] doc: memcontrol: fix the obsolete content about force empty
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 2, 2019 at 12:07 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> We don't do page cache reparent anymore when offlining memcg, so update
> force empty related content accordingly.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  Documentation/cgroup-v1/memory.txt | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> index 3682e99..8e2cb1d 100644
> --- a/Documentation/cgroup-v1/memory.txt
> +++ b/Documentation/cgroup-v1/memory.txt
> @@ -70,7 +70,7 @@ Brief summary of control files.
>   memory.soft_limit_in_bytes     # set/show soft limit of memory usage
>   memory.stat                    # show various statistics
>   memory.use_hierarchy           # set/show hierarchical account enabled
> - memory.force_empty             # trigger forced move charge to parent
> + memory.force_empty             # trigger forced page reclaim
>   memory.pressure_level          # set memory pressure notifications
>   memory.swappiness              # set/show swappiness parameter of vmscan
>                                  (See sysctl's vm.swappiness)
> @@ -459,8 +459,9 @@ About use_hierarchy, see Section 6.
>    the cgroup will be reclaimed and as many pages reclaimed as possible.
>
>    The typical use case for this interface is before calling rmdir().
> -  Because rmdir() moves all pages to parent, some out-of-use page caches can be
> -  moved to the parent. If you want to avoid that, force_empty will be useful.
> +  Though rmdir() offlines memcg, but the memcg may still stay there due to
> +  charged file caches. Some out-of-use page caches may keep charged until
> +  memory pressure happens. If you want to avoid that, force_empty will be useful.
>
>    Also, note that when memory.kmem.limit_in_bytes is set the charges due to
>    kernel pages will still be seen. This is not considered a failure and the
> --
> 1.8.3.1
>
