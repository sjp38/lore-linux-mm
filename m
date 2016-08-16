Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7120A6B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 04:41:36 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 65so171094989uay.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 01:41:36 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id i10si24335659wjm.3.2016.08.16.01.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 01:41:35 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so15156387wmg.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 01:41:35 -0700 (PDT)
Date: Tue, 16 Aug 2016 10:41:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
Message-ID: <20160816084132.GA17417@dhcp22.suse.cz>
References: <57A325CA.9050707@huawei.com>
 <57A3260F.4050709@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57A3260F.4050709@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 04-08-16 19:25:03, Xishi Qiu wrote:
> MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
> set one pageblock's migratetype in deferred_free_range() if pfn is aligned
> to MAX_ORDER_NR_PAGES.

Do I read the changelog correctly and the bug causes leaking unmovable
allocations into movable zones?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
