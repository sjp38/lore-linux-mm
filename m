Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39D138E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 05:13:04 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so33668949edq.4
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 02:13:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si8761048edr.185.2019.01.03.02.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 02:13:02 -0800 (PST)
Date: Thu, 3 Jan 2019 11:13:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] doc: memcontrol: fix the obsolete content about
 force empty
Message-ID: <20190103101302.GI31793@dhcp22.suse.cz>
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546459533-36247-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1546459533-36247-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 04:05:31, Yang Shi wrote:
> We don't do page cache reparent anymore when offlining memcg, so update
> force empty related content accordingly.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Thanks for the clean up.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  Documentation/cgroup-v1/memory.txt | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> index 3682e99..8e2cb1d 100644
> --- a/Documentation/cgroup-v1/memory.txt
> +++ b/Documentation/cgroup-v1/memory.txt
> @@ -70,7 +70,7 @@ Brief summary of control files.
>   memory.soft_limit_in_bytes	 # set/show soft limit of memory usage
>   memory.stat			 # show various statistics
>   memory.use_hierarchy		 # set/show hierarchical account enabled
> - memory.force_empty		 # trigger forced move charge to parent
> + memory.force_empty		 # trigger forced page reclaim
>   memory.pressure_level		 # set memory pressure notifications
>   memory.swappiness		 # set/show swappiness parameter of vmscan
>  				 (See sysctl's vm.swappiness)
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

-- 
Michal Hocko
SUSE Labs
