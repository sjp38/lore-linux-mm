Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2513B6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 04:33:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so268044173pgi.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 01:33:21 -0800 (PST)
Received: from out0-141.mail.aliyun.com (out0-141.mail.aliyun.com. [140.205.0.141])
        by mx.google.com with ESMTP id s5si979363plj.103.2017.01.25.01.33.19
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 01:33:20 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
In-Reply-To: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: Use static global work_struct for draining per-cpu pages
Date: Wed, 25 Jan 2017 17:33:16 +0800
Message-ID: <004201d276ee$0f20fd80$2d62f880$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Tejun Heo' <tj@kernel.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>


On Wednesday, January 25, 2017 4:31 PM Mel Gorman wrote: 
> 
> As suggested by Vlastimil Babka and Tejun Heo, this patch uses a static
> work_struct to co-ordinate the draining of per-cpu pages on the workqueue.
> Only one task can drain at a time but this is better than the previous
> scheme that allowed multiple tasks to send IPIs at a time.
> 
> One consideration is whether parallel requests should synchronise against
> each other. This patch does not synchronise for a global drain as the common
> case for such callers is expected to be multiple parallel direct reclaimers
> competing for pages when the watermark is close to min. Draining the per-cpu
> list is unlikely to make much progress and serialising the drain is of
> dubious merit. Drains are synchonrised for callers such as memory hotplug
> and CMA that care about the drain being complete when the function returns.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
