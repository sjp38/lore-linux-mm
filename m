Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3D66B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:16:59 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id n3so101864657wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:16:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si28529145wjx.30.2016.04.11.05.16.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 05:16:57 -0700 (PDT)
Subject: Re: [PATCH 07/11] mm, compaction: Update compaction_result ordering
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-8-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570B95B6.6030509@suse.cz>
Date: Mon, 11 Apr 2016 14:16:54 +0200
MIME-Version: 1.0
In-Reply-To: <1459855533-4600-8-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/05/2016 01:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> compaction_result will be used as the primary feedback channel for
> compaction users. At the same time try_to_compact_pages (and potentially
> others) assume a certain ordering where a more specific feedback takes
> precendence. This gets a bit awkward when we have conflicting feedback
> from different zones. E.g one returing COMPACT_COMPLETE meaning the full
> zone has been scanned without any outcome while other returns with
> COMPACT_PARTIAL aka made some progress. The caller should get
> COMPACT_PARTIAL because that means that the compaction still can make
> some progress. The same applies for COMPACT_PARTIAL vs.
> COMPACT_PARTIAL_SKIPPED. Reorder PARTIAL to be the largest one so the
> larger the value is the more progress we have done.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
