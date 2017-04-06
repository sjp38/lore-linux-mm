Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id F1C856B040B
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 07:03:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l132so27710509oia.10
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 04:03:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o84si563314oib.304.2017.04.06.04.03.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 04:03:49 -0700 (PDT)
Subject: Re: [PATCH v8] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201704062002.FAE18212.OJOFOHLStFVFQM@I-love.SAKURA.ne.jp>
Date: Thu, 6 Apr 2017 20:02:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru, lists@wiesinger.com, hughd@google.com

Andrew, anything else I can do?

Tetsuo Handa wrote:
>   Regarding maintenance burden, I consider this patch is least invasive
>   because it does not make __GFP_NOWARN flag's semantic confusing while
>   providing administrators some hints [4]. Also, this patch will remain
>   useful because we might overlook something that can cause infinite
>   loop (or significant delay) in future changes, and we can remove this
>   patch when we achieve safe and robust memory management subsystem.
> 
> Changes from v7 [11]:
> 
>   (1) Reflect review comments from Andrew Morton. (Convert "u8 type" to
>       "bool report", use CPUHP_PAGE_ALLOC_DEAD event and replace
>       for_each_possible_cpu() with for_each_online_cpu(), reuse existing
>       rcu_lock_break() and hung_timeout_jiffies() for now, update comments).

We are still sometimes overlooking unexpected delays like
http://lkml.kernel.org/r/alpine.LSU.2.11.1704051331420.4288@eggly.anvils and
http://lkml.kernel.org/r/da13c3c7-b514-67b0-2eb9-6d6af277901b@wiesinger.com
and I think we will in the future. I believe that this patch is helpful for
catching such cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
