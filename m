Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0000A6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 07:45:08 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id r91so329457965uar.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:45:08 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id f125si5336688qkc.248.2016.08.04.04.45.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 04:45:08 -0700 (PDT)
Message-ID: <57A328BB.2040700@huawei.com>
Date: Thu, 4 Aug 2016 19:36:27 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
References: <57A325CA.9050707@huawei.com> <57A3260F.4050709@huawei.com>
In-Reply-To: <57A3260F.4050709@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/8/4 19:25, Xishi Qiu wrote:

> MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
> set one pageblock's migratetype in deferred_free_range() if pfn is aligned
> to MAX_ORDER_NR_PAGES.
> 
> Also we missed to free the last block in deferred_init_memmap().
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Sorry for the typo, this patch is 3/3, and 1/3 is this one
"[PATCH 1/3] mem-hotplug: introduce movablenode option"

However they are all independent.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
