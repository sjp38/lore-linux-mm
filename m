Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB6FD6B025F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:47:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so30155585wmd.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:47:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o4si1508561edb.240.2017.10.10.05.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Oct 2017 05:47:58 -0700 (PDT)
Date: Tue, 10 Oct 2017 08:47:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmalloc: back off only when the current task is OOM
 killed
Message-ID: <20171010124749.GA16710@cmpxchg.org>
References: <1507633133-5720-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507633133-5720-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, alan@llwyncelyn.cymru, hch@lst.de, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Oct 10, 2017 at 07:58:53PM +0900, Tetsuo Handa wrote:
> Commit 5d17a73a2ebeb8d1 ("vmalloc: back off when the current task is
> killed") revealed two bugs [1] [2] that were not ready to fail vmalloc()
> upon SIGKILL. But since the intent of that commit was to avoid unlimited
> access to memory reserves, we should have checked tsk_is_oom_victim()
> rather than fatal_signal_pending().
> 
> Note that even with commit cd04ae1e2dc8e365 ("mm, oom: do not rely on
> TIF_MEMDIE for memory reserves access"), it is possible to trigger
> "complete depletion of memory reserves" and "extra OOM kills due to
> depletion of memory reserves" by doing a large vmalloc() request if commit
> 5d17a73a2ebeb8d1 is reverted. Thus, let's keep checking tsk_is_oom_victim()
> rather than removing fatal_signal_pending().

Nothing has changed since the last time you proposed this.

Who is doing large vmallocs, and why shouldn't we annotate what's
special instead of littering generic code with checks for unlikely
events?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
