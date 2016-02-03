Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4226082963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:57:53 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id n128so22962578pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:57:53 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id v13si12283048pas.128.2016.02.03.15.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 15:57:52 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id 65so23156774pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:57:52 -0800 (PST)
Date: Wed, 3 Feb 2016 15:57:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] oom reaper: handle mlocked pages
In-Reply-To: <1454505240-23446-3-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1602031557320.10331@chino.kir.corp.google.com>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org> <1454505240-23446-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 3 Feb 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> __oom_reap_vmas current skips over all mlocked vmas because they need a
> special treatment before they are unmapped. This is primarily done for
> simplicity. There is no reason to skip over them and reduce the amount
> of reclaimed memory. This is safe from the semantic point of view
> because try_to_unmap_one during rmap walk would keep tell the reclaim
> to cull the page back and mlock it again.
> 
> munlock_vma_pages_all is also safe to be called from the oom reaper
> context because it doesn't sit on any locks but mmap_sem (for read).
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
