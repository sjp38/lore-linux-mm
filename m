Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i8O3qFfO014918
	for <linux-mm@kvack.org>; Thu, 23 Sep 2004 20:52:16 -0700 (PDT)
Date: Thu, 23 Sep 2004 20:51:58 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Patch/RFC]Removing zone and node ID from page->flags[0/3]
In-Reply-To: <20040923232713.GJ9106@holomorphy.com>
References: <20040923135108.D8CC.YGOTO@us.fujitsu.com> <20040923232713.GJ9106@holomorphy.com>
Message-Id: <20040923203516.0207.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Thank you for comment.

> Looks relatively innocuous. I wonder if cosmetically we may want
> s/struct zone_tbl/struct zone_table/

Do you mean "struct zone_table" is better as its name?
If so, I'll change it.

> I like the path compression in the 2-level radix tree.

Hmmmm.....
Current radix tree code uses slab allocator.
But, zone_table must be initialized before free_all_bootmem()
and kmem_cache_alloc().
So, if I use it for zone_table, I think I have to change radix tree
code to use bootmem or have to write other original code.
I'm not sure it is better way....

Bye.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
