Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA4806B025E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:58:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i85so67688969pfa.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 00:58:35 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id q14si9857041pgn.63.2016.10.13.00.58.34
        for <linux-mm@kvack.org>;
        Thu, 13 Oct 2016 00:58:35 -0700 (PDT)
Date: Thu, 13 Oct 2016 16:58:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 4/4] mm, page_alloc: disallow migratetype fallback in
 fastpath
Message-ID: <20161013075856.GC2306@js1304-P5Q-DELUXE>
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
 <20160929210548.26196-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929210548.26196-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, Sep 29, 2016 at 11:05:48PM +0200, Vlastimil Babka wrote:
> The previous patch has adjusted async compaction so that it helps against
> longterm fragmentation when compacting for a non-MOVABLE high-order allocation.
> The goal of this patch is to force such allocations go through compaction
> once before being allowed to fallback to a pageblock of different migratetype
> (e.g. MOVABLE). In contexts where compaction is not allowed (and for order-0
> allocations), this delayed fallback possibility can still help by trying a
> different zone where fallback might not be needed and potentially waking up
> kswapd earlier.

Hmm... can we justify this compaction overhead in case of that there is
high order freepages in other migratetype pageblock? There is no guarantee
that longterm fragmentation happens and it affects the system
peformance.

And, it would easilly fail to compact in unmovable pageblock since
there would not be migratable pages if everything works as our
intended. So, I guess that checking it over and over doesn't help to
reduce fragmentation and just increase latency of allocation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
