Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1B50F6B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 10:18:24 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so3833336eek.3
        for <linux-mm@kvack.org>; Fri, 23 May 2014 07:18:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p41si7153021eem.34.2014.05.23.07.18.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 07:18:22 -0700 (PDT)
Date: Fri, 23 May 2014 16:18:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 8/9] mm: memcontrol: rewrite charge API
Message-ID: <20140523141820.GE22135@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-9-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-9-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 30-04-14 16:25:42, Johannes Weiner wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d3961fce1d54..6f48e292ffe7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2574,163 +2574,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  	return NOTIFY_OK;
>  }
>  
> -/**
> - * mem_cgroup_try_charge - try charging a memcg
> - * @memcg: memcg to charge
> - * @nr_pages: number of pages to charge
> - * @oom: trigger OOM if reclaim fails
> - *
> - * Returns 0 if @memcg was charged successfully, -EINTR if the charge
> - * was bypassed to root_mem_cgroup, and -ENOMEM if the charge failed.
> - */
> -static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
> -				 gfp_t gfp_mask,
> -				 unsigned int nr_pages,
> -				 bool oom)

Why haven't you simply renamed mem_cgroup_try_charge to try_charge here?
The code move is really hard to review.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
