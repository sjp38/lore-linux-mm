Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA4B76B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:01:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 190so222649679pgg.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:01:08 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id s9si573596plj.8.2017.03.13.07.01.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 07:01:03 -0700 (PDT)
Message-ID: <58C6A5C5.9070301@huawei.com>
Date: Mon, 13 Mar 2017 21:59:33 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
References: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com> <20170313111947.rdydbpblymc6a73x@techsingularity.net>
In-Reply-To: <20170313111947.rdydbpblymc6a73x@techsingularity.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org

On 2017/3/13 19:19, Mel Gorman wrote:
> On Mon, Mar 13, 2017 at 04:02:54PM +0800, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
>> introduced to the mainline, free_pcppages_bulk irq_save/resave to protect
>> the IRQ context. but drain_pages_zone fails to clear away the irq. because
>> preempt_disable have take effect. so it safely remove the code.
>>
>> Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> It's not really a fix but is this even measurable?
>
> The reason the IRQ saving was preserved was for callers that are removing
> the CPU where it's not 100% clear if the CPU is protected from IPIs at
> the time the pcpu drain takes place. It may be ok but the changelog
> should include an indication that it has been considered and is known to
> be fine versus CPU hotplug.
>
you mean the removing cpu maybe  handle the IRQ, it will result in the incorrect pcpu->count ?

but I don't sure that dying cpu remain handle the IRQ.

Thanks
zhongjinag

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
