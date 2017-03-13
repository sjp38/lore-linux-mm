Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E87FE6B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:19:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w37so45632297wrc.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:19:49 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id r126si10450497wmb.109.2017.03.13.04.19.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 04:19:48 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 3423598BB2
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:19:48 +0000 (UTC)
Date: Mon, 13 Mar 2017 11:19:47 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
Message-ID: <20170313111947.rdydbpblymc6a73x@techsingularity.net>
References: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org

On Mon, Mar 13, 2017 at 04:02:54PM +0800, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> when commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> introduced to the mainline, free_pcppages_bulk irq_save/resave to protect
> the IRQ context. but drain_pages_zone fails to clear away the irq. because
> preempt_disable have take effect. so it safely remove the code.
> 
> Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

It's not really a fix but is this even measurable?

The reason the IRQ saving was preserved was for callers that are removing
the CPU where it's not 100% clear if the CPU is protected from IPIs at
the time the pcpu drain takes place. It may be ok but the changelog
should include an indication that it has been considered and is known to
be fine versus CPU hotplug.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
