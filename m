Date: Mon, 10 Oct 2005 15:46:36 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Benchmarks to exploit LRU deficiencies
Message-ID: <20051010184636.GA15415@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

There are a few experimental implementations of advanced replacement
algorithms being developed and discussed. Unfortunately, there is lack of
knowledge on how to properly test them.

I've set up a page on the Linux-MM wiki with the intent to describe
LRU's weaknesses and collect benchmarks which exhibit its problems.

Contributions are essential to get this moving, please help.

At the moment there is one test (miniDB) available.

http://www.linux-mm.org/PageReplacementTesting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
