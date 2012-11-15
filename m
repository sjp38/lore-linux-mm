Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 775A16B006E
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:27:08 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1584639pbc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 13:27:07 -0800 (PST)
Date: Thu, 15 Nov 2012 13:27:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix a regression with HIGHMEM introduced by changeset
 7f1290f2f2a4d
In-Reply-To: <20121115112454.e582a033.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1211151326500.27188@chino.kir.corp.google.com>
References: <1352165517-9732-1-git-send-email-jiang.liu@huawei.com> <20121106124315.79deb2bc.akpm@linux-foundation.org> <50A3B013.4030207@gmail.com> <20121115112454.e582a033.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <liuj97@gmail.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Jianguo Wu <wujianguo@huawei.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Vetter <daniel.vetter@ffwll.ch>

On Thu, 15 Nov 2012, Andrew Morton wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: revert "mm: fix-up zone present pages"
> 
> Revert
> 
> commit 7f1290f2f2a4d2c3f1b7ce8e87256e052ca23125
> Author:     Jianguo Wu <wujianguo@huawei.com>
> AuthorDate: Mon Oct 8 16:33:06 2012 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Tue Oct 9 16:22:54 2012 +0900
> 
>     mm: fix-up zone present pages
> 
> 
> That patch tried to fix a issue when calculating zone->present_pages, but
> it caused a regression on 32bit systems with HIGHMEM.  With that
> changeset, reset_zone_present_pages() resets all zone->present_pages to
> zero, and fixup_zone_present_pages() is called to recalculate
> zone->present_pages when the boot allocator frees core memory pages into
> buddy allocator.  Because highmem pages are not freed by bootmem
> allocator, all highmem zones' present_pages becomes zero.
> 
> Various options for improving the situation are being discussed but for
> now, let's return to the 3.6 code.
> 
> Cc: Jianguo Wu <wujianguo@huawei.com>
> Cc: Jiang Liu <jiang.liu@huawei.com>
> Cc: Petr Tesarik <ptesarik@suse.cz>
> Cc: "Luck, Tony" <tony.luck@intel.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
