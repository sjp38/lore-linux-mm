Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B232B6B0068
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 04:12:02 -0400 (EDT)
Date: Mon, 10 Sep 2012 09:11:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120910081156.GD11266@suse.de>
References: <20120910011830.GC3715@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120910011830.GC3715@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com

On Mon, Sep 10, 2012 at 09:18:30AM +0800, Shaohua Li wrote:
> isolate_migratepages_range() might isolate none pages, for example, when
> zone->lru_lock is contended and compaction is async. In this case, we should
> abort compaction, otherwise, compact_zone will run a useless loop and make
> zone->lru_lock is even contended.
> 
> V2:
> only abort the compaction if lock is contended or run too long
> Rearranged the code by Andrea Arcangeli.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
