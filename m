Subject: Re: [RFC][PATCH] Sparse Memory Handling (hot-add foundation)
References: <1108685033.6482.38.camel@localhost>
From: Andi Kleen <ak@muc.de>
Date: Fri, 18 Feb 2005 11:04:06 +0100
In-Reply-To: <1108685033.6482.38.camel@localhost> (Dave Hansen's message of
 "Thu, 17 Feb 2005 16:03:53 -0800")
Message-ID: <m1zmy2b2w9.fsf@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <haveblue@us.ibm.com> writes:

> The attached patch, largely written by Andy Whitcroft, implements a
> feature which is similar to DISCONTIGMEM, but has some added features.
> Instead of splitting up the mem_map for each NUMA node, this splits it
> up into areas that represent fixed blocks of memory.  This allows
> individual pieces of that memory to be easily added and removed.

[...]

I'm curious - how does this affect .text size for a i386 or x86-64 NUMA
kernel? One area I wanted to improve on x86-64 for a long time was
to shrink the big virt_to_page() etc. inline macros. Your new code
actually looks a bit smaller.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
