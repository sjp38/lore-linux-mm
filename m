Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DBEBC6B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:48:48 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id a140so13715737wma.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:48:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id up10si28890034wjc.216.2016.04.11.06.48.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 06:48:47 -0700 (PDT)
Subject: Re: [PATCH 08/11] mm, compaction: Simplify
 __alloc_pages_direct_compact feedback interface
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-9-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570BAB3E.1060601@suse.cz>
Date: Mon, 11 Apr 2016 15:48:46 +0200
MIME-Version: 1.0
In-Reply-To: <1459855533-4600-9-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/05/2016 01:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> __alloc_pages_direct_compact communicates potential back off by two
> variables:
> 	- deferred_compaction tells that the compaction returned
> 	  COMPACT_DEFERRED
> 	- contended_compaction is set when there is a contention on
> 	  zone->lock resp. zone->lru_lock locks
>
> __alloc_pages_slowpath then backs of for THP allocation requests to
> prevent from long stalls. This is rather messy and it would be much
> cleaner to return a single compact result value and hide all the nasty
> details into __alloc_pages_direct_compact.

On the other hand, the nasty subtle details of THP allocation handling 
are now split between __alloc_pages_direct_compact and 
__alloc_pages_slowpath(). Lesser evil, I guess. I wish we could get rid 
of these special cases, now that latency of THP direct allocations is 
reduced by Mel's new defaults.

> This patch shouldn't introduce any functional changes.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
