Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9616B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 01:13:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so45006212pfy.2
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 22:13:10 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b5si1472526pgn.280.2016.11.06.22.13.08
        for <linux-mm@kvack.org>;
        Sun, 06 Nov 2016 22:13:09 -0800 (PST)
Date: Mon, 7 Nov 2016 15:15:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 2/6] mm/cma: introduce new zone, ZONE_CMA
Message-ID: <20161107061500.GA21159@js1304-P5Q-DELUXE>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
 <58184B28.8090405@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <58184B28.8090405@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 01, 2016 at 03:58:32PM +0800, Chen Feng wrote:
> Hello, I hava a question on cma zone.
> 
> When we have cma zone, cma zone will be the highest zone of system.
> 
> In android system, the most memory allocator is ION. Media system will
> alloc unmovable memory from it.
> 
> On low memory scene, will the CMA zone always do balance?

Allocation request for low zone (normal zone) would not cause CMA zone
to be balanced since it isn't helpful.

> Should we transmit the highest available zone to kswapdi 1/4 ?

It is already done when necessary.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
