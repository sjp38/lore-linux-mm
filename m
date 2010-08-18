Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E36986B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 04:15:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I8F1L8006473
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Wed, 18 Aug 2010 17:15:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AB1945DE51
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:15:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE50E45DE4F
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:15:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C6C641DB8038
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:15:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ABEA1DB803B
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:14:57 +0900 (JST)
Message-ID: <4385155269B445AEAF27DC8639A953D7@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <325E0A25FE724BA18190186F058FF37E@rainbow> <20100817111018.GQ19797@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Date: Wed, 18 Aug 2010 17:19:21 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-15";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> In other words, what is it that is supposed to increase the "inactive"
>> or decrease the "isolated" so that isolated > inactive becomes false?
>>
> 
> See places that update the NR_ISOLATED_ANON and NR_ISOLATED_FILE
> counters.

Many thanks for the advice.
So far as I understand, to come out of the loop, somehow NR_ISOLATED_*
has to be decremented. And the code that decrements it is called here:
mm/migrate.c migrate_pages() -> unmap_and_move()

In compaction.c, migrate_pages() is called only after returning from 
isolate_migratepages().
So if it is looping inside isolate_migratepages() function, migrate_pages()
will not be called and hence there is no chance for NR_ISOLATED_*
to be decremented. Am I wrong?

Best regards
Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
