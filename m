Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC0CE6B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 18:22:20 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w1-v6so161227ply.12
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 15:22:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t63-v6sor3055302pfi.74.2018.07.13.15.22.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 15:22:19 -0700 (PDT)
Date: Fri, 13 Jul 2018 15:22:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context
 information
In-Reply-To: <1531482952-4595-1-git-send-email-ufo19890607@gmail.com>
Message-ID: <alpine.DEB.2.21.1807131521030.202408@chino.kir.corp.google.com>
References: <1531482952-4595-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Fri, 13 Jul 2018, ufo19890607@gmail.com wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 531b2c86d4db..7fbd389ea779 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -434,10 +434,11 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  			oom_constraint_text[oc->constraint],
>  			nodemask_pr_args(oc->nodemask));
>  	cpuset_print_current_mems_allowed();
> +	mem_cgroup_print_oom_context(oc->memcg, p);
>  	pr_cont(",task=%s,pid=%5d,uid=%5d\n", p->comm, p->pid,
>  		from_kuid(&init_user_ns, task_uid(p)));
>  	if (is_memcg_oom(oc))
> -		mem_cgroup_print_oom_info(oc->memcg, p);
> +		mem_cgroup_print_oom_meminfo(oc->memcg);
>  	else {
>  		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>  		if (is_dump_unreclaim_slabs())

Ugh, could we please not pad the pid and uid with spaces?  I don't think 
it achieves anything and just makes regex less robust.

Otherwise, looks good!
