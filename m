Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A2B4F6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:22:55 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so4104807wgh.32
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 05:22:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si17553526wja.128.2014.07.25.05.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 05:22:53 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:22:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V4 03/15] mm, compaction: do not count compact_stall if
 all zones skipped compaction
Message-ID: <20140725122249.GX10819@suse.de>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
 <1405518503-27687-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405518503-27687-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Jul 16, 2014 at 03:48:11PM +0200, Vlastimil Babka wrote:
> The compact_stall vmstat counter counts the number of allocations stalled by
> direct compaction. It does not count when all attempted zones had deferred
> compaction, but it does count when all zones skipped compaction. The skipping
> is decided based on very early check of compaction_suitable(), based on
> watermarks and memory fragmentation. Therefore it makes sense not to count
> skipped compactions as stalls. Moreover, compact_success or compact_fail is
> also already not being counted when compaction was skipped, so this patch
> changes the compact_stall counting to match the other two.
> 
> Additionally, restructure __alloc_pages_direct_compact() code for better
> readability.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
