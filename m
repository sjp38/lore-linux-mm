Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id A483D6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 01:01:16 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id cl4so48375643igb.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 22:01:16 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 9si18406078ioq.35.2016.03.21.22.01.15
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 22:01:15 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:02:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/6] mm/page_alloc: fix same zone check in
 __pageblock_pfn_to_page()
Message-ID: <20160322050244.GA31955@js1304-P5Q-DELUXE>
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1457940697-2278-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20160321113719.GM28876@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160321113719.GM28876@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Mon, Mar 21, 2016 at 11:37:19AM +0000, Mel Gorman wrote:
> On Mon, Mar 14, 2016 at 04:31:32PM +0900, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > There is a system that node's pfn are overlapped like as following.
> > 
> > -----pfn-------->
> > N0 N1 N2 N0 N1 N2
> > 
> > Therefore, we need to care this overlapping when iterating pfn range.
> > 
> > In __pageblock_pfn_to_page(), there is a check for this but it's
> > not sufficient. This check cannot distinguish the case that zone id
> > is the same but node id is different. This patch fixes it.
> > 
> 
> I think you may be mixing up page_zone_id with page_zonenum.

Oops... Indeed.

I will drop the patch. Thanks for catching it. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
