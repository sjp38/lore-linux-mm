Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B32B66B0033
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 09:42:14 -0400 (EDT)
Date: Thu, 15 Aug 2013 14:42:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130815134209.GW2296@suse.de>
References: <20130814155205.GA2706@gmail.com>
 <20130814161642.GM2296@suse.de>
 <20130814163921.GC2706@gmail.com>
 <20130814180012.GO2296@suse.de>
 <520C3DD2.8010905@huawei.com>
 <20130815024427.GA2718@gmail.com>
 <520C4EFF.8040305@huawei.com>
 <20130815041736.GA2592@gmail.com>
 <20130815113019.GV2296@suse.de>
 <20130815131935.GA8437@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130815131935.GA8437@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 15, 2013 at 10:19:35PM +0900, Minchan Kim wrote:
> > 
> > Why? We're looking for pages to migrate. If the page is free and at the
> > maximum order then there is no point searching in the middle of a free
> > page.
> 
> isolate_migratepages_range API works with [low_pfn, end_pfn)
> and we can't guarantee page_order in normal compaction path
> so I'd like to limit the skipping by end_pfn conservatively.
> 

Fine

s/MAX_ORDER_NR_PAGES/pageblock_nr_pages/

and take the min of it and

low_pfn = min(low_pfn, end_pfn - 1)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
