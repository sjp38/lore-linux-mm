Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 392BC6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 04:25:05 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c206so35408736wme.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 01:25:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 132si21565738wmp.119.2017.01.25.01.25.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 01:25:03 -0800 (PST)
Subject: Re: [PATCH] mm, page_alloc: Use static global work_struct for
 draining per-cpu pages
References: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <69ddadc2-906c-7f4f-9a93-70a40b16e018@suse.cz>
Date: Wed, 25 Jan 2017 10:24:43 +0100
MIME-Version: 1.0
In-Reply-To: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/25/2017 09:30 AM, Mel Gorman wrote:
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

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
