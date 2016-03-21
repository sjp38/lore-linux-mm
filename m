Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7696B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:37:27 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so118078212wmp.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 04:37:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v80si4946454wmv.40.2016.03.21.04.37.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 04:37:25 -0700 (PDT)
Date: Mon, 21 Mar 2016 11:37:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/6] mm/page_alloc: fix same zone check in
 __pageblock_pfn_to_page()
Message-ID: <20160321113719.GM28876@suse.de>
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1457940697-2278-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1457940697-2278-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Mar 14, 2016 at 04:31:32PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> There is a system that node's pfn are overlapped like as following.
> 
> -----pfn-------->
> N0 N1 N2 N0 N1 N2
> 
> Therefore, we need to care this overlapping when iterating pfn range.
> 
> In __pageblock_pfn_to_page(), there is a check for this but it's
> not sufficient. This check cannot distinguish the case that zone id
> is the same but node id is different. This patch fixes it.
> 

I think you may be mixing up page_zone_id with page_zonenum.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
