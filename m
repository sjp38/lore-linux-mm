Date: Thu, 26 Oct 2000 13:52:45 -0200
From: "Rodrigo S. de Castro" <rcastro@linux.ime.usp.br>
Subject: ptes flags in compressed cache
Message-ID: <20001026135245.B19100@linux.ime.usp.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

	I am working on a compressed cache for 2.2.16 and I am
currently in a cache with no compression implementation. Well, at this
step, I gotta a doubt of how can I mark the pages (actually, ptes)
that are in my cache and neither present in memory nor in swap. This
is essential when I have a page fault, and this page is not present in
memory. It is (in a normal kernel) assumed to be in swap, but it can,
now, be in my cache. In order to mark the pte, I first thought of a
flag (in the style of _PAGE_*), and I defined _PAGE_COMPRESSED with
0x200, because all before were used. However, I got into a big
trouble. An address like 0xe00 is a valid swap address, and returns
true when I and it with 0x200. Thus, my question is: is there an
offset in swap address that allows me to use this part of address to
put a flag of mine in that free space? And, even more importante, do
you have any other idea to solve that? Maybe a better solution, that
does not depend on swap implementation and any future change would not
screw my current solution up. I don't have any idea of what might have
been changed on 2.4, so that's the main reason of asking you and be
trying to avoid possible troubles! :-)

PS: There's a simple page of my project. Give a look at:
    http://tutu.ime.usp.br

[]'s
-- 
Rodrigo S. de Castro   <rcastro@linux.ime.usp.br>
Computer Science undergraduate student - University of Sao Paulo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
