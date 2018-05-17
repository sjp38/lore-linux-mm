Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3BB76B0399
	for <linux-mm@kvack.org>; Thu, 17 May 2018 03:11:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b25-v6so2202320pfn.10
        for <linux-mm@kvack.org>; Thu, 17 May 2018 00:11:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15-v6si3608387pgu.352.2018.05.17.00.11.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 May 2018 00:11:46 -0700 (PDT)
Date: Thu, 17 May 2018 09:11:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Add the memcg print oom info for system oom
Message-ID: <20180517071140.GQ12670@dhcp22.suse.cz>
References: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

On Thu 17-05-18 08:00:28, ufo19890607 wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The dump_header does not print the memcg's name when the system
> oom happened. Some users want to locate the certain container
> which contains the task that has been killed by the oom killer.
> So I add the mem_cgroup_print_oom_info when system oom events
> happened.

The oom report is quite heavy today. Do we really need the full memcg
oom report here. Wouldn't it be sufficient to print the memcg the task
belongs to?

> Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
> ---
>  mm/oom_kill.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8ba6cb88cf58..244416c9834a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -433,6 +433,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  	if (is_memcg_oom(oc))
>  		mem_cgroup_print_oom_info(oc->memcg, p);
>  	else {
> +		mem_cgroup_print_oom_info(mem_cgroup_from_task(p), p);
>  		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>  		if (is_dump_unreclaim_slabs())
>  			dump_unreclaimable_slab();
> -- 
> 2.14.1
> 

-- 
Michal Hocko
SUSE Labs
