Message-Id: <3.0.6.32.20021021003415.007e6c30@boo.net>
Date: Mon, 21 Oct 2002 00:34:15 -0400
From: Jason Papadopoulos <jasonp@boo.net>
Subject: [PATCH] page coloring for 2.4.19 kernel
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello. This is a re-diff of the page coloring patch I've
been developing for the linux kernel. The actual changes
are very minor (small cleanups, added a license, small linked
list changes), and it works fine on my test box (at least it
passes all the tests that older patches passed).

www.boo.net/~jasonp/page_color-2.2.20-20020108.patch
www.boo.net/~jasonp/page_color-2.4.17-20020113.patch
www.boo.net/~jasonp/page_color-2.4.18-20020705.patch
www.boo.net/~jasonp/page_color-2.4.19-20021020.patch

At this point I'm getting a bit dissatisfied with the state of
the patch...the ideal for me would be to make it completely invisible.
Just type in the cache size as a kernel boot parameter and off it
goes; no starting or stopping, and no worries about moving all the 
free list pointers over to other data structures and then moving them
all back again when you don't want page coloring anymore. You should
*always* want page coloring :)

That unfortunately would require replacing lots of low-level MM code
that I barely understand (sorry, beginning kernel hacker). And you run
into a chicken-and-egg problem in that maximum cache efficiency requires
either 

1. Knowing the cache size early in the boot process, or 

2. Statically allocating a huge number of colors that may be overkill for
   your particular machine.

I also want to make some allowances for NUMA systems and systems with
discontiguous memory. What's a sensible way to allocate pages by color 
when there are possibly many different nodes? Should each zone have a 
round-robin counter of its own? Or should each process have its own 
counter like it does now, and grab consecutive colors from each zone
no matter how far away the physical memory is?

Where do you insert custom boot flags in the 2.4 kernel? The 2.2 kernel
interface for that stuff seems to have disappeared.

I'm not subscribed to LKML, so please cc responses to this email address.

Thanks,
jasonp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
