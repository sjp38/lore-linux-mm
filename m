Message-ID: <400F630F.80205@cyberone.com.au>
Date: Thu, 22 Jan 2004 16:43:43 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [BENCHMARKS] Namesys VM patches improve kbuild
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <Nikita@Namesys.COM>
List-ID: <linux-mm.kvack.org>

Hi,

The two namesys patches help kbuild quite a lot here.
http://www.kerneltrap.org/~npiggin/vm/1/

The patches can be found at
http://thebsh.namesys.com/snapshots/LATEST/extra/

I don't have much to comment on the patches. They do include
some cleanup stuff which should be broken out.

I don't really understand the dont-rotate-active-list patch:
I don't see why we're losing LRU information because the pages
that go to the head of the active list get their referenced
bits cleared.

Anyway, comments?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
