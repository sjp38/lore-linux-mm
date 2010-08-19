Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B5A406B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 03:05:19 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7J75H6V010451
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Thu, 19 Aug 2010 16:05:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F21BC45DE4D
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:05:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C2A3E45DE6E
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:05:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 96DC5EF8001
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:05:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 512851DB803A
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:05:16 +0900 (JST)
Message-ID: <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <325E0A25FE724BA18190186F058FF37E@rainbow> <20100817111018.GQ19797@csn.ul.ie> <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost>
Subject: Re: compaction: trying to understand the code
Date: Thu, 19 Aug 2010 16:09:38 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> The loop should be waiting for the _other_ processes (doing direct
> reclaims) to proceed.  When there are _lots of_ ongoing page
> allocations/reclaims, it makes sense to wait for them to calm down a bit?

I have noticed that if I run other process, it helps the loop to exit.
So is this (ie hanging until other process helps) intended behaviour?

Also, the other process does help the loop to exit, but again it enters
the loop and the compaction is never finished. That is, the process
looks like hanging. Is this intended behaviour?
What will improve this situation?

Thanks
Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
