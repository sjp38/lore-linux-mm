Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE0F6B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:38:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v8so5655504wrd.21
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:38:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si2057401edj.349.2017.11.20.01.38.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 01:38:52 -0800 (PST)
Date: Mon, 20 Nov 2017 10:38:51 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Use min watermark for last second
 allocation attempt.
Message-ID: <20171120093851.gs3zqpmmyacxplor@dhcp22.suse.cz>
References: <1510915081-3768-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510915081-3768-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri 17-11-17 19:38:01, Tetsuo Handa wrote:
[...]
> [ 1792.835056] Out of memory: Kill process 14294 (idle-priority) score 876 or sacrifice child
> [ 1792.836073] Killed process 14458 (normal-priority) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB

Wen you are in a situation when you are killing 88kB process then you
are most probably going to suffer more oom kills anyway. Optimizing for
this case is thus questionable at best. You would need to come up with
a reasonable explanation why the livelock as described by Andrea is not
possible with the current MM reclaim retry implementation. I am not
saying the patch is wrong but your justification _is_ wrong.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
