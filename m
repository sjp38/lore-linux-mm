Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5D82C6B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 21:12:55 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so6310122pdi.13
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 18:12:54 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id to10si24021905pbc.228.2014.06.23.18.12.53
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 18:12:54 -0700 (PDT)
Message-ID: <53A8D092.4040801@lge.com>
Date: Tue, 24 Jun 2014 10:12:50 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [RFC] CMA page migration failure due to buffers on bh_lru
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, =?EUC-KR?B?wMywx8ij?= <gunho.lee@lge.com>


Hello,

I am trying to apply CMA feature for my platform.
My kernel version, 3.10.x, is not allocating memory from CMA area so that I applied
a Joonsoo Kim's patch (https://lkml.org/lkml/2014/5/28/64).
Now my platform can use CMA area effectively.

But I have many failures to allocate memory from CMA area.
I found the same situation to Laura Abbott's patch descrbing, https://lkml.org/lkml/2012/8/31/313,
that releases buffer-heads attached at CPU's LRU list.

If Joonsoo's patch is applied and/or CMA feature is applied more and more,
buffer-heads problem is going to be serious definitely.

Please look into the Laura's patch again.
I think it must be applied with Joonsoo's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
