Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACB028024F
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:57:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b130so67922964wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:57:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wi9si13801080wjb.186.2016.09.29.02.57.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 02:57:06 -0700 (PDT)
Subject: Re: [PATCH 3/4] mm, compaction: ignore fragindex from
 compaction_zonelist_suitable()
References: <20160926162025.21555-1-vbabka@suse.cz>
 <20160926162025.21555-4-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cadadd38-6456-f58e-504f-cc18ddc47b3f@suse.cz>
Date: Thu, 29 Sep 2016 11:57:01 +0200
MIME-Version: 1.0
In-Reply-To: <20160926162025.21555-4-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>

On 09/26/2016 06:20 PM, Vlastimil Babka wrote:
> The compaction_zonelist_suitable() function tries to determine if compaction
> will be able to proceed after sufficient reclaim, i.e. whether there are
> enough reclaimable pages to provide enough order-0 freepages for compaction.
> 
> This addition of reclaimable pages to the free pages works well for the order-0
> watermark check, but in the fragmentation index check we only consider truly
> free pages. Thus we can get fragindex value close to 0 which indicates failure
> do to lack of memory, and wrongly decide that compaction won't be suitable even
> after reclaim.
> 
> Instead of trying to somehow adjust fragindex for reclaimable pages, let's just
> skip it from compaction_zonelist_suitable().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>

Bah, a fix below, sorry.
----8<----
