Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE5996B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 04:12:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so34643794lfd.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:12:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jo9si3419558wjc.10.2016.05.04.01.12.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 May 2016 01:12:48 -0700 (PDT)
Subject: Re: [PATCH 0.14] oom detection rework v6
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5729AEFB.9060101@suse.cz>
Date: Wed, 4 May 2016 10:12:43 +0200
MIME-Version: 1.0
In-Reply-To: <20160504054502.GA10899@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 05/04/2016 07:45 AM, Joonsoo Kim wrote:
> I still don't agree with some part of this patchset that deal with
> !costly order. As you know, there was two regression reports from Hugh
> and Aaron and you fixed them by ensuring to trigger compaction. I
> think that these show the problem of this patchset. Previous kernel
> doesn't need to ensure to trigger compaction and just works fine in
> any case.

IIRC previous kernel somehow subtly never OOM'd for !costly orders. So 
anything that introduces the possibility of OOM may look like regression 
for some corner case workloads. But I don't think that it's OK to not 
OOM for e.g. kernel stack allocations?

> Your series make compaction necessary for all. OOM handling
> is essential part in MM but compaction isn't. OOM handling should not
> depend on compaction. I tested my own benchmark without
> CONFIG_COMPACTION and found that premature OOM happens.
>
> I hope that you try to test something without CONFIG_COMPACTION.

Hmm a valid point, !CONFIG_COMPACTION should be considered. But reclaim 
cannot guarantee forming an order>0 page. But neither does OOM. So would 
you suggest we keep reclaiming without OOM as before, to prevent these 
regressions? Or where to draw the line here?

> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
