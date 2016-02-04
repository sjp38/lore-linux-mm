Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEE74403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 17:31:29 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id cy9so22642826pac.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 14:31:29 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id y11si19199022pas.239.2016.02.04.14.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 14:31:28 -0800 (PST)
Received: by mail-pa0-x234.google.com with SMTP id yy13so22487802pab.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 14:31:28 -0800 (PST)
Date: Thu, 4 Feb 2016 14:31:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] mm, oom_reaper: report success/failure
In-Reply-To: <20160204064636.GD8581@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1602041428120.29117@chino.kir.corp.google.com>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org> <1454505240-23446-5-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1602031505210.10331@chino.kir.corp.google.com> <20160204064636.GD8581@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 4 Feb 2016, Michal Hocko wrote:

> > I think it would be helpful to show anon-rss after reaping, however, so we 
> > can compare to the previous anon-rss that was reported.  And, I agree that 
> > leaving behind a message in the kernel log that reaping has been 
> > successful is worthwhile.  So this line should just show what anon-rss is 
> > after reaping and make it clear that this is not the memory reaped.
> 
> Does
> "oom_reaper: reaped process %d (%s) current memory anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB "
> 
> sound any better?

oom_reaper: reaped process %d (%s), now anon-rss:%lukB

would probably be better until additional support is added to do other 
kinds of reaping other than just primarily heap.  This should help to 
quantify the exact amount of memory that could be reaped (or otherwise 
unmapped) iff oom_reaper has to get involved rather than fluctations that 
have nothing to do with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
