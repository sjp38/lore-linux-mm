Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 281B08E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 04:39:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so15763203edi.0
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 01:39:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si1348029edr.27.2018.12.19.01.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 01:39:40 -0800 (PST)
Date: Wed, 19 Dec 2018 10:39:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v15 2/2] Add oom victim's memcg to the oom context
 information
Message-ID: <20181219093938.GA5758@dhcp22.suse.cz>
References: <20181122133954.GI18011@dhcp22.suse.cz>
 <CAHCio2gdCX3p-7=N0cA22cWTaUmUXRq8WbiMAA2sM2wLVX4GjQ@mail.gmail.com>
 <201812190723.wBJ7NdkN032628@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201812190723.wBJ7NdkN032628@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Wed 19-12-18 16:23:39, Tetsuo Handa wrote:
> Andrew, will you fold below diff into "mm, oom: add oom victim's memcg to the oom context information" ?
> 
> >From add1e8daddbfc5186417dbc58e9e11e7614868f8 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 19 Dec 2018 16:09:31 +0900
> Subject: [PATCH] mm, oom: Use pr_cont() in mem_cgroup_print_oom_context().
> 
> One line summary of the OOM killer context is not one line due to
> not using KERN_CONT.
> 
> [   23.346650] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0
> [   23.346691] ,global_oom,task_memcg=/,task=firewalld,pid=5096,uid=0
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Sorry, I have missed that during review. Thanks for catching this up!

> ---
>  mm/memcontrol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b860dd4f7..4afd597 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1306,10 +1306,10 @@ void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *
>  	rcu_read_lock();
>  
>  	if (memcg) {
> -		pr_info(",oom_memcg=");
> +		pr_cont(",oom_memcg=");
>  		pr_cont_cgroup_path(memcg->css.cgroup);
>  	} else
> -		pr_info(",global_oom");
> +		pr_cont(",global_oom");
>  	if (p) {
>  		pr_cont(",task_memcg=");
>  		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
