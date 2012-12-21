Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id C64C56B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 22:55:13 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id vb8so4180918obc.34
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:55:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121219141218.c1bb423b.akpm@linux-foundation.org>
References: <1355925061-3858-1-git-send-email-handai.szj@taobao.com>
	<20121219141218.c1bb423b.akpm@linux-foundation.org>
Date: Fri, 21 Dec 2012 11:55:12 +0800
Message-ID: <CAFj3OHWDdiKiY+MJXnUw9y0v=Z0XiUsCBeYXWpwf1iMbkzeqhw@mail.gmail.com>
Subject: Re: [PATCH V5] memcg, oom: provide more precise dump info while memcg
 oom happening
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, Sha Zhengju <handai.szj@taobao.com>

On Thu, Dec 20, 2012 at 6:12 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 19 Dec 2012 21:51:01 +0800
> Sha Zhengju <handai.szj@gmail.com> wrote:
>
>> +             pr_info("Memory cgroup stats");
>
> Well if we're going to do that, we may as well finish the job:
>
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/memcontrol.c: convert printk(KERN_FOO) to pr_foo()
>
> Cc: Sha Zhengju <handai.szj@taobao.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/memcontrol.c |   15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
>
> diff -puN mm/memcontrol.c~mm-memcontrolc-convert-printkkern_foo-to-pr_foo mm/memcontrol.c
> --- a/mm/memcontrol.c~mm-memcontrolc-convert-printkkern_foo-to-pr_foo
> +++ a/mm/memcontrol.c
> @@ -1574,7 +1574,7 @@ void mem_cgroup_print_oom_info(struct me
>         }
>         rcu_read_unlock();
>
> -       printk(KERN_INFO "Task in %s killed", memcg_name);
> +       pr_info("Task in %s killed", memcg_name);
>
>         rcu_read_lock();
>         ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
> @@ -1587,19 +1587,18 @@ void mem_cgroup_print_oom_info(struct me
>         /*
>          * Continues from above, so we don't need an KERN_ level
>          */
> -       printk(KERN_CONT " as a result of limit of %s\n", memcg_name);
> +       pr_cont(" as a result of limit of %s\n", memcg_name);
>  done:
>
> -       printk(KERN_INFO "memory: usage %llukB, limit %llukB, failcnt %llu\n",
> +       pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
>                 res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
>                 res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
>                 res_counter_read_u64(&memcg->res, RES_FAILCNT));
> -       printk(KERN_INFO "memory+swap: usage %llukB, limit %llukB, "
> -               "failcnt %llu\n",
> +       pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %llu\n",
>                 res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
>                 res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
>                 res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
> -       printk(KERN_INFO "kmem: usage %llukB, limit %llukB, failcnt %llu\n",
> +       pr_info("kmem: usage %llukB, limit %llukB, failcnt %llu\n",
>                 res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
>                 res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
>                 res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
> @@ -4424,8 +4423,8 @@ void mem_cgroup_print_bad_page(struct pa
>
>         pc = lookup_page_cgroup_used(page);
>         if (pc) {
> -               printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
> -                      pc, pc->flags, pc->mem_cgroup);
> +               pr_alert("pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
> +                        pc, pc->flags, pc->mem_cgroup);
>         }
>  }
>  #endif
> _
>


Thanks Andrew! : )

Acked-by: Sha Zhengju <handai.szj@taobao.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
