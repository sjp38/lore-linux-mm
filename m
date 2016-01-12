Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4665E4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 03:16:45 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so306629662wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 00:16:45 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 201si29362329wml.102.2016.01.12.00.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 00:16:43 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id b14so30050754wmb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 00:16:43 -0800 (PST)
Date: Tue, 12 Jan 2016 09:16:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20160112081641.GC25337@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452094975-551-2-git-send-email-mhocko@kernel.org>
 <20160111145455.51e183aed810f7d366ea50a0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160111145455.51e183aed810f7d366ea50a0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 11-01-16 14:54:55, Andrew Morton wrote:
> On Wed,  6 Jan 2016 16:42:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > - use subsys_initcall instead of module_init - Paul Gortmaker
> 
> That's pretty much the only change between what-i-have and
> what-you-sent, so I'll just do this as a delta:

Yeah that should be the case, thanks for double checking!
 
> --- a/mm/oom_kill.c~mm-oom-introduce-oom-reaper-v4
> +++ a/mm/oom_kill.c
> @@ -32,12 +32,11 @@
>  #include <linux/mempolicy.h>
>  #include <linux/security.h>
>  #include <linux/ptrace.h>
> -#include <linux/delay.h>
>  #include <linux/freezer.h>
>  #include <linux/ftrace.h>
>  #include <linux/ratelimit.h>
>  #include <linux/kthread.h>
> -#include <linux/module.h>
> +#include <linux/init.h>
>  
>  #include <asm/tlb.h>
>  #include "internal.h"
> @@ -542,7 +541,7 @@ static int __init oom_init(void)
>  	}
>  	return 0;
>  }
> -module_init(oom_init)
> +subsys_initcall(oom_init)
>  #else
>  static void wake_oom_reaper(struct mm_struct *mm)
>  {
> _

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
