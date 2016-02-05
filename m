Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8E03D4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 04:26:43 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id g62so18366327wme.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 01:26:43 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ld8si13784125wjc.77.2016.02.05.01.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 01:26:42 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id p63so2097420wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 01:26:42 -0800 (PST)
Date: Fri, 5 Feb 2016 10:26:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/5] mm, oom_reaper: report success/failure
Message-ID: <20160205092640.GA5477@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-5-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1602031505210.10331@chino.kir.corp.google.com>
 <20160204064636.GD8581@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602041428120.29117@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602041428120.29117@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 04-02-16 14:31:26, David Rientjes wrote:
> On Thu, 4 Feb 2016, Michal Hocko wrote:
> 
> > > I think it would be helpful to show anon-rss after reaping, however, so we 
> > > can compare to the previous anon-rss that was reported.  And, I agree that 
> > > leaving behind a message in the kernel log that reaping has been 
> > > successful is worthwhile.  So this line should just show what anon-rss is 
> > > after reaping and make it clear that this is not the memory reaped.
> > 
> > Does
> > "oom_reaper: reaped process %d (%s) current memory anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB "
> > 
> > sound any better?
> 
> oom_reaper: reaped process %d (%s), now anon-rss:%lukB
> 
> would probably be better until additional support is added to do other 
> kinds of reaping other than just primarily heap.  This should help to 
> quantify the exact amount of memory that could be reaped (or otherwise 
> unmapped) iff oom_reaper has to get involved rather than fluctations that 
> have nothing to do with it.

---
