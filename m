Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF17F6B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 21:34:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b17-v6so485122pff.17
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 18:34:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e193-v6sor682631pgc.16.2018.07.03.18.34.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 18:34:50 -0700 (PDT)
Date: Tue, 3 Jul 2018 18:34:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: be more informative in OOM task list
In-Reply-To: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com>
Message-ID: <alpine.DEB.2.21.1807031832540.110853@chino.kir.corp.google.com>
References: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rodrigo Freire <rfreire@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 1 Jul 2018, Rodrigo Freire wrote:

> The default page memory unit of OOM task dump events might not be
> intuitive for the non-initiated when debugging OOM events. Add
> a small printk prior to the task dump informing that the memory
> units are actually memory _pages_.
> 
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

As the author of dump_tasks(), and having seen these values misinterpreted 
on more than one occassion, I think this is a valuable addition.

Could you also expand out the "pid" field to allow for seven digits 
instead of five?  I think everything else is aligned.

Feel free to add

Acked-by: David Rientjes <rientjes@google.com>

to a v2.
