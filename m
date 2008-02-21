Message-ID: <47BD55F6.5030203@firstfloor.org>
Date: Thu, 21 Feb 2008 11:44:06 +0100
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <200802211535.38932.nickpiggin@yahoo.com.au> <47BD06C2.5030602@linux.vnet.ibm.com>
In-Reply-To: <47BD06C2.5030602@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 1. We could create something similar to mem_map, we would need to handle 4

4? At least x86 mainline only has two ways now. flatmem and vmemmap.

> different ways of creating mem_map.

Well it would be only a single way to create the "aux memory controller
map" (or however it will be called). Basically just a call to single
function from a few different places.

> 2. On x86 with 64 GB ram, 

First i386 with 64GB just doesn't work, at least not with default 3:1
split. Just calculate it yourself how much of the lowmem area is left
after the 64GB mem_map is allocated. Typical rule of thumb is that 16GB
is the realistic limit for 32bit x86 kernels. Worrying about
anything more does not make much sense.

> if we decided to use vmalloc space, we would need 64
> MB of vmalloc'ed memory

Yes and if you increase mem_map you need exactly the same space
in lowmem too. So increasing the vmalloc reservation for this is
equivalent. Just make sure you use highmem backed vmalloc.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
