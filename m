Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 132036B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 08:45:49 -0500 (EST)
Date: Mon, 18 Jan 2010 21:44:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] memory-hotplug: add 0x prefix to HEX block_size_bytes
Message-ID: <20100118134429.GD721@localhost>
References: <20100114115956.GA2512@localhost> <20100114152907.953f8d3e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114152907.953f8d3e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > -	return sprintf(buf, "%lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
> > +	return sprintf(buf, "%#lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
 
> crappy changelog!
> 
> Why this change?  Perhaps showing us an example of the before-and-after
> output would help us see what is being fixed, and why.

Sorry for being late (some SMTP problem).

                # cat /sys/devices/system/memory/block_size_bytes
before patch:   8000000
after  patch:   0x8000000

This is a good fix because someone is very likely to mistake 8000000
as a decimal number. 0x8000000 looks much better.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
