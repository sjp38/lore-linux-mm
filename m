Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4B116B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 05:23:48 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id m60so172476445uam.3
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:23:48 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id u1si24449742wju.85.2016.08.16.02.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 02:23:47 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so15343012wmg.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:23:47 -0700 (PDT)
Date: Tue, 16 Aug 2016 11:23:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
Message-ID: <20160816092345.GB17417@dhcp22.suse.cz>
References: <57A325CA.9050707@huawei.com>
 <57A3260F.4050709@huawei.com>
 <20160816084132.GA17417@dhcp22.suse.cz>
 <57B2D556.5030201@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57B2D556.5030201@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 16-08-16 16:56:54, Xishi Qiu wrote:
> On 2016/8/16 16:41, Michal Hocko wrote:
> 
> > On Thu 04-08-16 19:25:03, Xishi Qiu wrote:
> >> MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
> >> set one pageblock's migratetype in deferred_free_range() if pfn is aligned
> >> to MAX_ORDER_NR_PAGES.
> > 
> > Do I read the changelog correctly and the bug causes leaking unmovable
> > allocations into movable zones?
> 
> Hi Michal,
> 
> This bug will cause uninitialized migratetype, you can see from
> "cat /proc/pagetypeinfo", almost half blocks are Unmovable.

Please add that information to the changelog. Leaking unmovable
allocations to the movable zones defeats the whole purpose of the
movable zone so I guess we really want to mark this for stable.
AFAICS it should also note:
Fixes: ac5d2539b238 ("mm: meminit: reduce number of times pageblocks are set during struct page init")
and stable 4.2+

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
