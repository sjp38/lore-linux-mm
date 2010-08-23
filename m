Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 23CDF6B038C
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 22:59:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7N2xeWQ029347
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Mon, 23 Aug 2010 11:59:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F2F545DE4F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 11:59:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7327245DE3E
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 11:59:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A20E1DB8050
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 11:59:40 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14EE21DB804C
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 11:59:40 +0900 (JST)
Message-ID: <C06122FE6B6044BD94C8A632B205D909@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <20100817111018.GQ19797@csn.ul.ie><4385155269B445AEAF27DC8639A953D7@rainbow><20100818154130.GC9431@localhost><565A4EE71DAC4B1A820B2748F56ABF73@rainbow><20100819160006.GG6805@barrios-desktop><AA3F2D89535A431DB91FE3032EDCB9EA@rainbow><20100820053447.GA13406@localhost><20100820093558.GG19797@csn.ul.ie><AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com><20100822153121.GA29389@barrios-desktop><20100822232316.GA339@localhost> <AANLkTim8c5C+vH1HUx-GsScirmnVoJXenLST1qQgk2bp@mail.gmail.com>
Subject: Re: compaction: trying to understand the code
Date: Mon, 23 Aug 2010 12:03:55 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> Iram. How do you execute test_app?
>
> 1) synchronous test
> 1.1 start test_app
> 1.2 wait test_app job done (ie, wait memory is fragment)
> 1.3 echo 1 > /proc/sys/vm/compact_memory
>
> 2) asynchronous test
> 2.1 start test_app
> 2.2 not wait test_app job done
> 2.3 echo 1 > /proc/sys/vm/compact_memory(Maybe your test app and
> compaction were executed parallel)

It's synchronous.
First I confirm that the test app has completed its fragmentation work
by looking at the printf output. Then only I run echo 1 > 
/proc/sys/vm/compact_memory.

After completing fragmentation work, my test app sleeps in a useless while 
loop
which I think is not important.

Thanks
Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
