Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 2FC886B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 11:55:25 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id n10so1064631oag.28
        for <linux-mm@kvack.org>; Tue, 16 Jul 2013 08:55:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1373901620-2021-17-git-send-email-mgorman@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
	<1373901620-2021-17-git-send-email-mgorman@suse.de>
Date: Tue, 16 Jul 2013 23:55:24 +0800
Message-ID: <CAJd=RBAxApb2Hoz06_7Ry1Z-TSAWGp9QJCfLP5NPPm2kiUF+Bg@mail.gmail.com>
Subject: Re: [PATCH 16/18] sched: Avoid overloading CPUs on a preferred NUMA node
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
> +
> +static int task_numa_find_cpu(struct task_struct *p, int nid)
> +{
> +       int node_cpu = cpumask_first(cpumask_of_node(nid));
[...]
>
> +       /* No harm being optimistic */
> +       if (idle_cpu(node_cpu))
> +               return node_cpu;
>
[...]
> +       for_each_cpu(cpu, cpumask_of_node(nid)) {
> +               dst_load = target_load(cpu, idx);
> +
> +               /* If the CPU is idle, use it */
> +               if (!dst_load)
> +                       return dst_cpu;
> +
Here you want cpu, instead of dst_cpu, I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
