Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 1F0306B00B0
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:38:40 -0400 (EDT)
Date: Tue, 11 Sep 2012 17:40:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120911084038.GB19698@bbox>
References: <20120910011830.GC3715@kernel.org>
 <20120911014555.GA14331@bbox>
 <20120911082946.GA801@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120911082946.GA801@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, aarcange@redhat.com

On Tue, Sep 11, 2012 at 04:29:46PM +0800, Shaohua Li wrote:
> On Tue, Sep 11, 2012 at 10:45:55AM +0900, Minchan Kim wrote:
> > On Mon, Sep 10, 2012 at 09:18:30AM +0800, Shaohua Li wrote:
> > > isolate_migratepages_range() might isolate none pages, for example, when
> > > zone->lru_lock is contended and compaction is async. In this case, we should
> > > abort compaction, otherwise, compact_zone will run a useless loop and make
> > > zone->lru_lock is even contended.
> > > 
> > 
> > As I read old thread, you have the scenario and number.
> > Please include them in this description.
> 
> that is just to show how the contention is, not performance data. I thought
> explaining the contention is enough. How did you think?

If you measured it with perf, you had data which is
percentage of sampling of the lock. It's enough. I meant it, NOT
performance data.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
