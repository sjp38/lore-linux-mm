Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A95876B02C4
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:41:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7K5fVM9013741
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Fri, 20 Aug 2010 14:41:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 299DE45DE51
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:41:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8EFD45DE53
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:41:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DEBD1DB8037
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:41:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0554FE18001
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:41:30 +0900 (JST)
Message-ID: <5EF4FA9117384B1A80228C96926B4125@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <325E0A25FE724BA18190186F058FF37E@rainbow> <20100817111018.GQ19797@csn.ul.ie> <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow> <20100819074602.GW19797@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Date: Fri, 20 Aug 2010 14:45:56 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-15";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> What is your test scenario? Who or what has these pages isolated that is
> allowing too_many_isolated() to be true?

I have a test app that attempts to create fragmentation. Then I run
echo 1 > /proc/sys/vm/compact_memory
That is all.
The test app mallocs 2MB 100 times, memsets them.
Then it frees the even numbered 2MB blocks.
That is, 2MB*50 remains malloced and 2MB*50 gets freed.

Thanks
Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
