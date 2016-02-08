Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 10A8A828E1
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 06:35:48 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id is5so147670504obc.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 03:35:48 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id ny9si15820491obc.30.2016.02.08.03.35.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 03:35:47 -0800 (PST)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 04:35:46 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6C5511FF0045
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:23:41 -0700 (MST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u18BZV386815818
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 11:35:31 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u18BZTOb017434
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 06:35:30 -0500
Message-ID: <56B87E32.4050003@linux.vnet.ibm.com>
Date: Mon, 08 Feb 2016 17:08:26 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [tip:sched/urgent] sched: Fix crash in sched_init_numa()
References: <1452884483-11676-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <tip-9c03ee147193645be4c186d3688232fa438c57c7@git.kernel.org>
In-Reply-To: <tip-9c03ee147193645be4c186d3688232fa438c57c7@git.kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@kernel.org, linux-mm@kvack.org, mpe@ellerman.id.au, hpa@zytor.com, nikunj@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, peterz@infradead.org, vdavydov@parallels.com, gkurz@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, raghavendra.kt@linux.vnet.ibm.com, jstancek@redhat.com, benh@kernel.crashing.org, anton@samba.org, grant.likely@linaro.org, paulus@samba.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org
Cc: tip-bot for Raghavendra K T <tipbot@zytor.com>, linux-tip-commits@vger.kernel.org

On 01/19/2016 07:08 PM, tip-bot for Raghavendra K T wrote:
> Commit-ID:  9c03ee147193645be4c186d3688232fa438c57c7
> Gitweb:     http://git.kernel.org/tip/9c03ee147193645be4c186d3688232fa438c57c7
> Author:     Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> AuthorDate: Sat, 16 Jan 2016 00:31:23 +0530
> Committer:  Ingo Molnar <mingo@kernel.org>
> CommitDate: Tue, 19 Jan 2016 08:42:20 +0100
>
> sched: Fix crash in sched_init_numa()
>
> The following PowerPC commit:
>
>    c118baf80256 ("arch/powerpc/mm/numa.c: do not allocate bootmem memory for non existing nodes")
>
> avoids allocating bootmem memory for non existent nodes.
>
> But when DEBUG_PER_CPU_MAPS=y is enabled, my powerNV system failed to boot
> because in sched_init_numa(), cpumask_or() operation was done on
> unallocated nodes.
>
> Fix that by making cpumask_or() operation only on existing nodes.
>
> [ Tested with and w/o DEBUG_PER_CPU_MAPS=y on x86 and PowerPC. ]
>
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Tested-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> Cc: <gkurz@linux.vnet.ibm.com>
> Cc: <grant.likely@linaro.org>
> Cc: <nikunj@linux.vnet.ibm.com>
> Cc: <vdavydov@parallels.com>
> Cc: <linuxppc-dev@lists.ozlabs.org>
> Cc: <linux-mm@kvack.org>
> Cc: <peterz@infradead.org>
> Cc: <benh@kernel.crashing.org>
> Cc: <paulus@samba.org>
> Cc: <mpe@ellerman.id.au>
> Cc: <anton@samba.org>
> Link: http://lkml.kernel.org/r/1452884483-11676-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>   kernel/sched/core.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 44253ad..474658b 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -6840,7 +6840,7 @@ static void sched_init_numa(void)
>
>   			sched_domains_numa_masks[i][j] = mask;
>
> -			for (k = 0; k < nr_node_ids; k++) {
> +			for_each_node(k) {
>   				if (node_distance(j, k) > sched_domains_numa_distance[i])
>   					continue;
>
>
>
>

Hello Greg,
Above commit fixes the debug kernel crash in 4.4 kernel [ when
DEBUG_PER_CPU_MAPS=y to be precise]. This is a regression in 4.4 from
4.3 and should be ideally present in 4.4-stable.

Could you please pull in this change.?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
