Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D51196B02DD
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 09:58:27 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so10108211pld.23
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 06:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v12-v6si13901922pgk.523.2018.07.09.06.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Jul 2018 06:58:26 -0700 (PDT)
Date: Mon, 9 Jul 2018 06:58:20 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER should always sleep at
 should_reclaim_retry().
Message-ID: <20180709135820.GB2662@bombadil.infradead.org>
References: <1531046158-4010-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180709075731.GB22049@dhcp22.suse.cz>
 <5a5ddca9-95fd-1035-b304-a9c6d50238b2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a5ddca9-95fd-1035-b304-a9c6d50238b2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Jul 09, 2018 at 10:08:04PM +0900, Tetsuo Handa wrote:
> > [Tetsuo: changelog]
> >> Signed-off-by: Michal Hocko <mhocko@suse.com>
> >> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> >> Cc: David Rientjes <rientjes@google.com>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Joonsoo Kim <js1304@gmail.com>
> >> Cc: Mel Gorman <mgorman@suse.de>
> >> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> >> Cc: Vlastimil Babka <vbabka@suse.cz>
> > 
> > Your s-o-b is still missing.
> 
> all code changes in this patch is from you. That is, my s-o-b is not missing.

   12) When to use Acked-by:, Cc:, and Co-Developed-by:
   -------------------------------------------------------

   The Signed-off-by: tag indicates that the signer was involved in the
   development of the patch, or that he/she was in the patch's delivery path.

That is, if you're submitting it, it needs your S-o-b line.  That's
written down in Documentation/process/submitting-patches.rst.
