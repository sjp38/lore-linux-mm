Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id CCAE36B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 08:17:29 -0400 (EDT)
Date: Thu, 6 Sep 2012 13:17:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2]compaction: check migrated page number
Message-ID: <20120906121725.GQ11266@suse.de>
References: <20120906104404.GA12718@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120906104404.GA12718@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com

On Thu, Sep 06, 2012 at 06:44:04PM +0800, Shaohua Li wrote:
> 
> isolate_migratepages_range() might isolate none pages, for example, when
> zone->lru_lock is contended and compaction is async. In this case, we should
> abort compaction, otherwise, compact_zone will run a useless loop and make
> zone->lru_lock is even contended.
> 

It might also isolate no pages because the range was 100% allocated and
there were no free pages to isolate. This is perfectly normal and I suspect
this patch effectively disables compaction. What problem did you observe
that this patch is aimed at?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
