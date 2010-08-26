Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 351016B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 04:01:09 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q816QJ021152
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Thu, 26 Aug 2010 17:01:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AE9045DE51
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 17:01:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1223845DE56
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 17:01:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EFCB41DB805D
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 17:01:05 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 98CCC1DB8060
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 17:01:05 +0900 (JST)
Message-ID: <132D72DD90BB458D8F0CF2D58C019517@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <20100818154130.GC9431@localhost><565A4EE71DAC4B1A820B2748F56ABF73@rainbow><20100819160006.GG6805@barrios-desktop><AA3F2D89535A431DB91FE3032EDCB9EA@rainbow><20100820053447.GA13406@localhost><20100820093558.GG19797@csn.ul.ie><AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com><20100822153121.GA29389@barrios-desktop><20100822232316.GA339@localhost><20100823171416.GA2216@barrios-desktop><20100824002753.GB6568@localhost><8E31CE28A1354C43BBAD0BDEFA10494E@rainbow> <AANLkTikTu3jx5WyYEDZY2mk99V+w7kxL5k7xJDS+QZ+m@mail.gmail.com>
Subject: Re: compaction: trying to understand the code
Date: Thu, 26 Aug 2010 17:05:41 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> What kinds of filesystem do you use?
> Do you boot from NFS?
> Do your system have any non-mainline(ie, doesn't merged into linux
> kernel tree) driver, file system or any feature?


I do not boot from NFS.
My system does have non-mainline file system and drivers.
I thought file system and drivers were irrelevant to this problem,
are they?

Thanks
Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
