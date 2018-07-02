Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEF466B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 05:30:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k5-v6so5432643edq.9
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 02:30:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4-v6si3623061edc.141.2018.07.02.02.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 02:30:47 -0700 (PDT)
Date: Mon, 2 Jul 2018 11:30:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: be more informative in OOM task list
Message-ID: <20180702093043.GB19043@dhcp22.suse.cz>
References: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rodrigo Freire <rfreire@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 01-07-18 13:09:40, Rodrigo Freire wrote:
> The default page memory unit of OOM task dump events might not be
> intuitive for the non-initiated when debugging OOM events. Add
> a small printk prior to the task dump informing that the memory
> units are actually memory _pages_.

Does this really help? I understand the the oom report might be not the
easiest thing to grasp but wouldn't it be much better to actually add
documentation with clarification of each part of it?

> Signed-off-by: Rodrigo Freire <rfreire@redhat.com>
> ---
>  mm/oom_kill.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 84081e7..b4d9557 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -392,6 +392,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  	struct task_struct *p;
>  	struct task_struct *task;
>  
> +	pr_info("Tasks state (memory values in pages):\n");
>  	pr_info("[ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>  	rcu_read_lock();
>  	for_each_process(p) {
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
