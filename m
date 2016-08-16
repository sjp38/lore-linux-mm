Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB1756B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 05:03:38 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so142986598pab.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:03:38 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id gk9si31243031pac.182.2016.08.16.02.03.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 02:03:37 -0700 (PDT)
Message-ID: <57B2D556.5030201@huawei.com>
Date: Tue, 16 Aug 2016 16:56:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
References: <57A325CA.9050707@huawei.com> <57A3260F.4050709@huawei.com> <20160816084132.GA17417@dhcp22.suse.cz>
In-Reply-To: <20160816084132.GA17417@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/8/16 16:41, Michal Hocko wrote:

> On Thu 04-08-16 19:25:03, Xishi Qiu wrote:
>> MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
>> set one pageblock's migratetype in deferred_free_range() if pfn is aligned
>> to MAX_ORDER_NR_PAGES.
> 
> Do I read the changelog correctly and the bug causes leaking unmovable
> allocations into movable zones?

Hi Michal,

This bug will cause uninitialized migratetype, you can see from
"cat /proc/pagetypeinfo", almost half blocks are Unmovable.

Also this bug missed to free the last block pages, it cause memory leaking.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
