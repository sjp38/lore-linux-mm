Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1IFgYHL002982
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 10:42:34 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1IFgYPn226576
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 10:42:34 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1IFgXwI029918
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 10:42:34 -0500
Subject: Re: [RFC][PATCH] Sparse Memory Handling (hot-add foundation)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <m1zmy2b2w9.fsf@muc.de>
References: <1108685033.6482.38.camel@localhost>  <m1zmy2b2w9.fsf@muc.de>
Content-Type: text/plain
Date: Fri, 18 Feb 2005 07:42:31 -0800
Message-Id: <1108741351.6482.61.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew E Tolentino <matthew.e.tolentino@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-02-18 at 11:04 +0100, Andi Kleen wrote:
> Dave Hansen <haveblue@us.ibm.com> writes:
> 
> > The attached patch, largely written by Andy Whitcroft, implements a
> > feature which is similar to DISCONTIGMEM, but has some added features.
> > Instead of splitting up the mem_map for each NUMA node, this splits it
> > up into areas that represent fixed blocks of memory.  This allows
> > individual pieces of that memory to be easily added and removed.
>
> I'm curious - how does this affect .text size for a i386 or x86-64 NUMA
> kernel? One area I wanted to improve on x86-64 for a long time was
> to shrink the big virt_to_page() etc. inline macros. Your new code
> actually looks a bit smaller.

On x86, it looks like a 3k increase in text size.  I know Matt Tolentino
has been testing it on x86_64, he might have a comparison there for you.

$ size i386-T41-laptop*/vmlinux
   text    data     bss     dec     hex filename
2897131  580592  204252 3681975  382eb7 i386-T41-laptop.sparse/vmlinux
2894166  581832  203228 3679226  3823fa i386-T41-laptop/vmlinux

BTW, this PAE is on and uses 36-bits of physaddr space.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
