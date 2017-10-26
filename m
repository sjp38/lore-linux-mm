Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF2F6B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:37:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z55so1773216wrz.2
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 07:37:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 4si2410090eds.41.2017.10.26.07.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Oct 2017 07:37:51 -0700 (PDT)
Date: Thu, 26 Oct 2017 10:37:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
Message-ID: <20171026143737.GC21147@cmpxchg.org>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Thu, Oct 26, 2017 at 08:28:59PM +0900, Tetsuo Handa wrote:
> [...] it is possible to trigger OOM lockup and/or soft lockups when
> many threads concurrently called warn_alloc() (in order to warn
> about memory allocation stalls) due to current implementation of
> printk(), and it is difficult to obtain useful information due to
> limitation of synchronous warning approach.
>
> [...]
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Reported-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Petr Mladek <pmladek@suse.com>

It would have been nice to be able to fix it instead, because there is
value in having the lockup detection. But it's true that it currently
causes more problems than it solves. Back to the drawing board for now.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks Tetsuo!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
