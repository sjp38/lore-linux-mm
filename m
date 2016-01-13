Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9895B828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:02:53 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id f206so382144095wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 09:02:53 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id mo12si3208073wjc.138.2016.01.13.09.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 09:02:51 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id b14so37999001wmb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 09:02:51 -0800 (PST)
Date: Wed, 13 Jan 2016 18:02:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 7/7] Documentation: cgroup: add
 memory.swap.{current,max} description
Message-ID: <20160113170250.GK17512@dhcp22.suse.cz>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
 <dbb4bf6bc071997982855c8f7d403c22cea60ffb.1450352792.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dbb4bf6bc071997982855c8f7d403c22cea60ffb.1450352792.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 17-12-15 15:30:00, Vladimir Davydov wrote:
> The rationale of separate swap counter is given by Johannes Weiner.
>
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Changes in v2:
>  - Add rationale of separate swap counter provided by Johannes.
> 
>  Documentation/cgroup.txt | 33 +++++++++++++++++++++++++++++++++

this went to Documentation/cgroup-v2.txt with the latest Tejun's pull
request.

>  1 file changed, 33 insertions(+)
> 
> diff --git a/Documentation/cgroup.txt b/Documentation/cgroup.txt
> index 31d1f7bf12a1..f441564023e1 100644
> --- a/Documentation/cgroup.txt
> +++ b/Documentation/cgroup.txt
> @@ -819,6 +819,22 @@ PAGE_SIZE multiple when read back.
>  		the cgroup.  This may not exactly match the number of
>  		processes killed but should generally be close.
>  
> +  memory.swap.current
> +
> +	A read-only single value file which exists on non-root
> +	cgroups.
> +
> +	The total amount of swap currently being used by the cgroup
> +	and its descendants.
> +
> +  memory.swap.max
> +
> +	A read-write single value file which exists on non-root
> +	cgroups.  The default is "max".
> +
> +	Swap usage hard limit.  If a cgroup's swap usage reaches this
> +	limit, anonymous meomry of the cgroup will not be swapped out.
> +
>  
>  5-2-2. General Usage
>  
> @@ -1291,3 +1307,20 @@ allocation from the slack available in other groups or the rest of the
>  system than killing the group.  Otherwise, memory.max is there to
>  limit this type of spillover and ultimately contain buggy or even
>  malicious applications.
> +
> +The combined memory+swap accounting and limiting is replaced by real
> +control over swap space.
> +
> +The main argument for a combined memory+swap facility in the original
> +cgroup design was that global or parental pressure would always be
> +able to swap all anonymous memory of a child group, regardless of the
> +child's own (possibly untrusted) configuration.  However, untrusted
> +groups can sabotage swapping by other means - such as referencing its
> +anonymous memory in a tight loop - and an admin can not assume full
> +swappability when overcommitting untrusted jobs.
> +
> +For trusted jobs, on the other hand, a combined counter is not an
> +intuitive userspace interface, and it flies in the face of the idea
> +that cgroup controllers should account and limit specific physical
> +resources.  Swap space is a resource like all others in the system,
> +and that's why unified hierarchy allows distributing it separately.
> -- 
> 2.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
