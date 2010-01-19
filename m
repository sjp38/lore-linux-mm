Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8C0856B0098
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 19:39:00 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0J0cv37029906
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Jan 2010 09:38:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E05845DE4E
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:38:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 42B8A45DD70
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:38:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AB321DB8038
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:38:57 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB4541DB8037
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:38:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memory-hotplug: add 0x prefix to HEX block_size_bytes
In-Reply-To: <20100118134429.GD721@localhost>
References: <20100114152907.953f8d3e.akpm@linux-foundation.org> <20100118134429.GD721@localhost>
Message-Id: <20100119093646.5F2B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Jan 2010 09:38:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > -	return sprintf(buf, "%lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
> > > +	return sprintf(buf, "%#lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
>  
> > crappy changelog!
> > 
> > Why this change?  Perhaps showing us an example of the before-and-after
> > output would help us see what is being fixed, and why.
> 
> Sorry for being late (some SMTP problem).
> 
>                 # cat /sys/devices/system/memory/block_size_bytes
> before patch:   8000000
> after  patch:   0x8000000
> 
> This is a good fix because someone is very likely to mistake 8000000
> as a decimal number. 0x8000000 looks much better.

I'm sorry. NAK.

print_block_size() was introduced at 2005. So, we can't assume any
programs don't use it.

Your patch is good, but too late...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
