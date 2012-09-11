Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C20B96B0085
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 21:56:13 -0400 (EDT)
Date: Tue, 11 Sep 2012 10:58:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 2/2 v2]compaction: check lock contention first before
 taking lock
Message-ID: <20120911015810.GB14331@bbox>
References: <20120910011850.GD3715@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120910011850.GD3715@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, aarcange@redhat.com

On Mon, Sep 10, 2012 at 09:18:50AM +0800, Shaohua Li wrote:
> isolate_migratepages_range will take zone->lru_lock first and check if the lock
> is contented, if yes, it will release the lock. This isn't efficient. If the
> lock is truly contented, a lock/unlock pair will increase the lock contention.
> We'd better check if the lock is contended first. compact_trylock_irqsave
> perfectly meets the requirement.
> 
> V2:
> leave cond_resched() pointed out by Mel.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
