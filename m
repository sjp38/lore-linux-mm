Message-ID: <401D8D64.8010605@cyberone.com.au>
Date: Mon, 02 Feb 2004 10:36:04 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: VM benchmarks
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

After playing with the active / inactive list balancing a bit,
I found I can very consistently take 2-3 seconds off a non
swapping kbuild, and the light swapping case is closer to 2.4.
Heavy swapping case is better again. Lost a bit in the middle
though.

http://www.kerneltrap.org/~npiggin/vm/4/

At the end of this I might come up with something that is very
suited to kbuild and no good at anything else. Do you have any
other ideas of what I should test?

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
