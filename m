Date: Fri, 23 Jun 2000 11:32:39 -0300
From: Rodrigo Castro <rcastro@linux.ime.usp.br>
Subject: Problems in compressed cache development
Message-ID: <20000623113239.A685@linux.ime.usp.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

	I am an undergraduate student at University of Sao Paulo,
Brazil and I am working on a compressed cache implementation for Linux
kernel. Our group (there are two more students plus two professors) is
working on version 2.2.14 and we are just crawling in our
development. We've been spending such a long time studying memory
management system and we've started working on source code for about
two months. We implemented some functions to initialize a slab cache,
this cache is supposed to be the heart of our system, and a function
that copies the first ten pages that goes to swap (yeah, the first 10
that go to disk). We did that by allocating a page using get_free_page
and copying memory data with copy_page macro. Well, everything worked
just fine until we put that to work. Our test machine had 22 Mb of
free memory. We allocated 20 Mb with a test program, and after that,
allocated 3 Mb in order to force swapping pages. What happened is our
second test program (the one that allocated 3 Mb) has been killed by
VM (message from kern.log: VM: killing process test). Well, we
replaced get_free_page by kmalloc and we had the same problem. A
sudden idea came to our mind that we should be updating some variable
related to the free pages number, but we couldn't find which one would
be this (these) variable(s). Well, I am writing to you 'cause I would
like to know if you could have an idea of what may be happening, or
what we could do to find a solution to that. We've been studying the
code, and reading many books, but unsuccesfully. Could you give us a
hand?

PS: We changed and allocated the 10 pages at initialization. Using
that, our test program worked, but it would be really useful to know
why we can't make it working allocating dynamically. 
PPS: After killing our process, if we run it again, trying to allocate
the 3 Mb, it works! Oh, the problem procedure is reproducible.

Thank you in advance,
-- 
Rodrigo Castro   <rcastro@linux.ime.usp.br>
Computer Science undergraduate student - University of Sao Paulo

Show me a sane man and I will cure him for you.
                -- C.G. Jung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
