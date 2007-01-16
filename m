Message-Id: <20070116094557.494892000@taijtu.programming.kicks-ass.net>
Date: Tue, 16 Jan 2007 10:45:57 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/9] VM deadlock avoidance -v10
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

These patches implement the basic infrastructure to allow swap over networked
storage.

The basic idea is to reserve some memory up front to use when regular memory
runs out.

To bound network behaviour we accept only a limited number of concurrent 
packets and drop those packets that are not aimed at the connection(s) servicing
the VM. Also all network paths that interact with userspace are to be avoided - 
e.g. taps and NF_QUEUE.

PF_MEMALLOC is set when processing emergency skbs. This makes sense in that we
are indeed working on behalf of the swapper/VM. This allows us to use the 
regular memory allocators for processing but requires that said processing have
bounded memory usage and has that accounted in the reserve.

I am particularly looking for comments on the design; is this acceptable?

Kind regards,
Peter
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
