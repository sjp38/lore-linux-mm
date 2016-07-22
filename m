Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3096B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:57:16 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r71so219874431ioi.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:57:16 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id n204si6009019oih.182.2016.07.22.01.57.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 01:57:15 -0700 (PDT)
Message-ID: <5791DFD4.5080207@huawei.com>
Date: Fri, 22 Jul 2016 16:56:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: mm/compact: why use low watermark to determine whether compact is
 finished instead of use high watermark?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mel@csn.ul.ie" <mel@csn.ul.ie>, Vlastimil Babka <vbabka@suse.cz>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

I find all the watermarks in mm/compaction.c are low_wmark_pages(),
so why not use high watermark to determine whether compact is finished?

e.g. 
__alloc_pages_nodemask()
	get_page_from_freelist()
	this is fast path, use use low_wmark_pages() in __zone_watermark_ok()

	__alloc_pages_slowpath()
	this is slow path, usually use min_wmark_pages()

kswapd
	balance_pgdat()
	use high_wmark_pages() to determine whether zone is balanced

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
