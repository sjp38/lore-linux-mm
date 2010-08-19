Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 23E1C6B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 03:45:08 -0400 (EDT)
Date: Thu, 19 Aug 2010 15:45:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100819074504.GA17393@localhost>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
 <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 03:09:38PM +0800, Iram Shahzad wrote:
> > The loop should be waiting for the _other_ processes (doing direct
> > reclaims) to proceed.  When there are _lots of_ ongoing page
> > allocations/reclaims, it makes sense to wait for them to calm down a bit?
> 
> I have noticed that if I run other process, it helps the loop to exit.
> So is this (ie hanging until other process helps) intended behaviour?
>
> Also, the other process does help the loop to exit, but again it enters
> the loop and the compaction is never finished. That is, the process
> looks like hanging. Is this intended behaviour?
> What will improve this situation?
 
What's your /proc/vmstat?  Does your system have thousands of
processes allocating memory concurrently? I'd like to make sure the
too_many_isolated() test is working as expected..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
