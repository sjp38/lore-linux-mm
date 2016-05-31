Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B901B6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 02:23:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so217468427pfs.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 23:23:58 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b8si35219830paw.151.2016.05.30.23.23.57
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 23:23:57 -0700 (PDT)
Date: Tue, 31 May 2016 15:25:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 03/13] mm, page_alloc: don't retry initial attempt in
 slowpath
Message-ID: <20160531062510.GB30967@js1304-P5Q-DELUXE>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, May 10, 2016 at 09:35:53AM +0200, Vlastimil Babka wrote:
> After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
> first tries get_page_from_freelist() with the new alloc_flags, as it may
> succeed e.g. due to using min watermark instead of low watermark. This attempt
> does not have to be retried on each loop, since direct reclaim, direct
> compaction and oom call get_page_from_freelist() themselves.

Hmm... there is a corner case. If did_some_progress is 0 or compaction
is deferred, get_page_from_freelist() isn't called. But, we can
succeed to allocate memory since there is a kswapd that reclaims
memory in background.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
