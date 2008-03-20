Message-Id: <20080320201042.675090000@chello.nl>
Date: Thu, 20 Mar 2008 21:10:42 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/30] Swap over NFS -v17
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, neilb@suse.de, miklos@szeredi.hu, penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Hi,

Patches against v2.6.25-rc5-mm1, also online at:
  http://programming.kicks-ass.net/kernel-patches/vm_deadlock/v2.6.25-rc5-mm1/

A quick post to keep people up-to-date and show I didn't forget about this :-)

The biggest changes are in the reservation code, introduction of allocation
helpers significantly cleaned up the rest of the code.

I still need to go through that and write more comments, but I wanted to get
this out there so people can have a look.

I also added Neil's excellent writeup to Documentation/ - I hope I didn't
ruin it too much :-)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
