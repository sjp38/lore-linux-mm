Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48B836B0279
	for <linux-mm@kvack.org>; Sun, 28 May 2017 03:01:08 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l78so26430868iod.4
        for <linux-mm@kvack.org>; Sun, 28 May 2017 00:01:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o3si7281083ite.25.2017.05.28.00.01.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 28 May 2017 00:01:07 -0700 (PDT)
Subject: Re: [PATCH v9] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201705281601.BBE81220.HFLOtSFFOJVQMO@I-love.SAKURA.ne.jp>
Date: Sun, 28 May 2017 16:01:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Changes from v7 [11]:
> 
>   (1) Reflect review comments from Andrew Morton. (Convert "u8 type" to
>       "bool report", use CPUHP_PAGE_ALLOC_DEAD event and replace
>       for_each_possible_cpu() with for_each_online_cpu(), reuse existing
>       rcu_lock_break() and hung_timeout_jiffies() for now, update comments).
> 
> Changes from v8 [12]:
> 
>   (1) Check mempool_alloc() as well, for mempool_alloc() is a sort of
>       open-coded __GFP_NOFAIL allocation request where warn_alloc() cannot
>       detect stalls due to __GFP_NORETRY, and actually I found a case where
>       kswapd was unable to get memory for bio from mempool at
>       bio_alloc_bioset(GFP_NOFS) [13], and I believe there are similar bugs.


Andrew, I believe it is time to start testing at linux-next.

Nobody shows interests in detecting/analyzing OOM livelock but there are
still unsolved suspicious cases

  http://lkml.kernel.org/r/da13c3c7-b514-67b0-2eb9-6d6af277901b@wiesinger.com
  http://lkml.kernel.org/r/20170502141544.rufykv6blliqzqfd@merlins.org
  http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com

where this patch might have given some clues if this patch were available.
There is no reason not to allow users to try this debugging aid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
