Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 696006B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 18:29:52 -0500 (EST)
Date: Thu, 14 Jan 2010 15:29:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory-hotplug: add 0x prefix to HEX block_size_bytes
Message-Id: <20100114152907.953f8d3e.akpm@linux-foundation.org>
In-Reply-To: <20100114115956.GA2512@localhost>
References: <20100114115956.GA2512@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jan 2010 19:59:56 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> CC: Andi Kleen <andi@firstfloor.org> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  drivers/base/memory.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-mm.orig/drivers/base/memory.c	2010-01-14 19:55:40.000000000 +0800
> +++ linux-mm/drivers/base/memory.c	2010-01-14 19:55:47.000000000 +0800
> @@ -311,7 +311,7 @@ static SYSDEV_ATTR(removable, 0444, show
>  static ssize_t
>  print_block_size(struct class *class, char *buf)
>  {
> -	return sprintf(buf, "%lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
> +	return sprintf(buf, "%#lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
>  }
>  
>  static CLASS_ATTR(block_size_bytes, 0444, print_block_size, NULL);

crappy changelog!

Why this change?  Perhaps showing us an example of the before-and-after
output would help us see what is being fixed, and why.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
