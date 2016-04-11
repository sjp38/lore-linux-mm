Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D3E156B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:02:23 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l6so140656692wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:02:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t187si17795804wmg.2.2016.04.11.04.02.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 04:02:22 -0700 (PDT)
Subject: Re: [PATCH 05/11] mm, compaction: distinguish COMPACT_DEFERRED from
 COMPACT_SKIPPED
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-6-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570B843C.8050608@suse.cz>
Date: Mon, 11 Apr 2016 13:02:20 +0200
MIME-Version: 1.0
In-Reply-To: <1459855533-4600-6-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/05/2016 01:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> try_to_compact_pages can currently return COMPACT_SKIPPED even when the
> compaction is defered for some zone just because zone DMA is skipped
> in 99% of cases due to watermark checks. This makes COMPACT_DEFERRED
> basically unusable for the page allocator as a feedback mechanism.
>
> Make sure we distinguish those two states properly and switch their
> ordering in the enum. This would mean that the COMPACT_SKIPPED will be
> returned only when all eligible zones are skipped.
>
> This shouldn't introduce any functional change.

Hmm, really? __alloc_pages_direct_compact() does distinguish 
COMPACT_DEFERRED, and sets *deferred compaction, so ultimately this is 
some change for THP allocations?

Also there's no mention of COMPACT_INACTIVE in the changelog (which 
indeed isn't functional change, but might surprise somebody).

> Signed-off-by: Michal Hocko <mhocko@suse.com>

Patch itself is OK.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
