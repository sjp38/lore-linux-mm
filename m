Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAC856B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 05:16:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p14so3960753wrg.7
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 02:16:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v76si1786432wmv.93.2017.08.29.02.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 02:16:22 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm/cma: manage the memory of the CMA area by using
 the ZONE_MOVABLE
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1503556593-10720-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <adae04f0-73f4-7772-d056-9ed13122af0e@suse.cz>
Date: Tue, 29 Aug 2017 11:16:18 +0200
MIME-Version: 1.0
In-Reply-To: <1503556593-10720-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2017 08:36 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> 0. History
> 
> This patchset is the follow-up of the discussion about the
> "Introduce ZONE_CMA (v7)" [1]. Please reference it if more information
> is needed.
> 

[...]

> 
> [1]: lkml.kernel.org/r/1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com
> [2]: https://lkml.org/lkml/2014/10/15/623
> [3]: http://www.spinics.net/lists/linux-mm/msg100562.html
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

The previous version has introduced ZONE_CMA, so I would think switching
to ZONE_MOVABLE is enough to drop previous reviews. Perhaps most of the
code involved is basically the same, though?

Anyway I checked the current patch and did some basic tests with qemu,
so you can keep my ack.

BTW, if we dropped NR_FREE_CMA_PAGES, could we also drop MIGRATE_CMA and
related hooks? Is that counter really that useful as it works right now?
It will decrease both by CMA allocations (which has to be explicitly
freed) and by movable allocations (which can be migrated). What if only
CMA alloc/release touched it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
