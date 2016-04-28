Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78F066B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:47:31 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y84so58250293lfc.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:47:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k88si14197706wmh.15.2016.04.28.01.47.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Apr 2016 01:47:30 -0700 (PDT)
Subject: Re: [PATCH 08/14] mm, compaction: Abstract compaction feedback to
 helpers
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-9-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5721CE20.6070801@suse.cz>
Date: Thu, 28 Apr 2016 10:47:28 +0200
MIME-Version: 1.0
In-Reply-To: <1461181647-8039-9-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/20/2016 09:47 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> Compaction can provide a wild variation of feedback to the caller. Many
> of them are implementation specific and the caller of the compaction
> (especially the page allocator) shouldn't be bound to specifics of the
> current implementation.
>
> This patch abstracts the feedback into three basic types:
> 	- compaction_made_progress - compaction was active and made some
> 	  progress.
> 	- compaction_failed - compaction failed and further attempts to
> 	  invoke it would most probably fail and therefore it is not
> 	  worth retrying
> 	- compaction_withdrawn - compaction wasn't invoked for an
>            implementation specific reasons. In the current implementation
>            it means that the compaction was deferred, contended or the
>            page scanners met too early without any progress. Retrying is
>            still worthwhile.
>
> [vbabka@suse.cz: do not change thp back off behavior]
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
