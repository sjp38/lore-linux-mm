Date: Fri, 13 Feb 2004 01:46:53 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: 2.6.3-rc2-mm1
Message-ID: <20040212144653.GH25922@krispykreme>
References: <20040212015710.3b0dee67.akpm@osdl.org> <20040212031322.742b29e7.akpm@osdl.org> <20040212115718.GF25922@krispykreme> <20040212040910.3de346d4.akpm@osdl.org> <Pine.LNX.4.58.0402120937460.32441@montezuma.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0402120937460.32441@montezuma.fsmlabs.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> I've not managed to trigger this one
> 
> CONFIG_DEBUG_KERNEL=y
> CONFIG_DEBUG_STACKOVERFLOW=y
> # CONFIG_DEBUG_SLAB is not set
> CONFIG_DEBUG_IOVIRT=y
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_PAGEALLOC=y
> CONFIG_DEBUG_HIGHMEM=y
> CONFIG_DEBUG_INFO=y
> CONFIG_DEBUG_SPINLOCK_SLEEP=y

Im guessing Andrews bug is my fault:

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc2/2.6.3-rc2-mm1/broken-out/ppc64-spinlock-sleep-debugging.patch

If you have preempt on you wont see it.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
