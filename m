Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1A7D16B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:41:45 -0400 (EDT)
Date: Wed, 18 Aug 2010 23:41:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100818154130.GC9431@localhost>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4385155269B445AEAF27DC8639A953D7@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 05:19:21PM +0900, Iram Shahzad wrote:
> >>In other words, what is it that is supposed to increase the "inactive"
> >>or decrease the "isolated" so that isolated > inactive becomes false?
> >>
> >
> >See places that update the NR_ISOLATED_ANON and NR_ISOLATED_FILE
> >counters.
> 
> Many thanks for the advice.
> So far as I understand, to come out of the loop, somehow NR_ISOLATED_*
> has to be decremented. And the code that decrements it is called here:
> mm/migrate.c migrate_pages() -> unmap_and_move()
> 
> In compaction.c, migrate_pages() is called only after returning from
> isolate_migratepages().
> So if it is looping inside isolate_migratepages() function, migrate_pages()
> will not be called and hence there is no chance for NR_ISOLATED_*
> to be decremented. Am I wrong?

The loop should be waiting for the _other_ processes (doing direct
reclaims) to proceed.  When there are _lots of_ ongoing page
allocations/reclaims, it makes sense to wait for them to calm down a bit?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
