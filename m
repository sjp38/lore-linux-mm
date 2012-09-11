Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 618286B00AE
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:29:54 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so520372pbb.14
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 01:29:53 -0700 (PDT)
Date: Tue, 11 Sep 2012 16:29:46 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120911082946.GA801@kernel.org>
References: <20120910011830.GC3715@kernel.org>
 <20120911014555.GA14331@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120911014555.GA14331@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, aarcange@redhat.com

On Tue, Sep 11, 2012 at 10:45:55AM +0900, Minchan Kim wrote:
> On Mon, Sep 10, 2012 at 09:18:30AM +0800, Shaohua Li wrote:
> > isolate_migratepages_range() might isolate none pages, for example, when
> > zone->lru_lock is contended and compaction is async. In this case, we should
> > abort compaction, otherwise, compact_zone will run a useless loop and make
> > zone->lru_lock is even contended.
> > 
> 
> As I read old thread, you have the scenario and number.
> Please include them in this description.

that is just to show how the contention is, not performance data. I thought
explaining the contention is enough. How did you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
