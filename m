Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 61DCC6B025E
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:23:24 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so31423808lfb.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:23:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n64si4017263wmn.41.2016.08.19.06.23.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 06:23:23 -0700 (PDT)
Subject: Re: [PATCH 00/34] Move LRU page reclaim from zones to nodes v9
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <20160819131200.kyqmfcabttkjvhe2@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5a560eab-cdf9-1961-1216-deff50cdf494@suse.cz>
Date: Fri, 19 Aug 2016 15:23:20 +0200
MIME-Version: 1.0
In-Reply-To: <20160819131200.kyqmfcabttkjvhe2@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 08/19/2016 03:12 PM, Andrea Arcangeli wrote:
> Hello Mel,

Hi Andrea,

> On Fri, Jul 08, 2016 at 10:34:36AM +0100, Mel Gorman wrote:
>> Minor changes this time
>>
>> Changelog since v8
>> This is the latest version of a series that moves LRUs from the zones to
>
> I'm afraid this is a bit incomplete...
>
> I had troubles in rebasing the compaction-enabled zone_reclaim feature
> (now node_reclaim) to the node model.

What's that? Never head of this before, but sounds scary :) I thought 
that zone_reclaim itself was rather discouraged nowadays, not a big 
candidate for further improvement.,,

> That is because compaction is
> still zone based, and so I would need to do a loop of compaction calls
> (for each zone in the node), but what's the point? Movable memory can
> always go anywhere, can't it?

Hm I'm not so sure. Are all movable allocations highmem? For example 
Joonsoo mentions in his ZONE_CMA patchset "blockdev file cache page 
[...] usually has __GFP_MOVABLE but not __GFP_HIGHMEM and __GFP_USER".
Now we also have Minchan's infrastructure for arbitrary driver 
compaction, so those will be movable, but potentially still restricted 
to e.g. DMA32...

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
