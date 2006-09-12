Message-Id: <20060912143049.278065000@chello.nl>
Subject: [PATCH 00/20] vm deadlock avoidance for NFS, NBD and iSCSI (take 7)
Date: Tue, 12 Sep 2006 17:25:49 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, Rik van Riel <riel@redhat.com>, Daniel Phillips <phillips@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

--

Yet another instance of my networked swap patches.

The patch-set consists of four parts:

 - patches 1-2; the basic 'framework' for deadlock avoidance
 - patches 3-9; implement swap over NFS
 - patches 10-13; implement swap over NBD
 - patches 14-20; implement swap over iSCSI

The iSCSI work depends on their .19 tree and does need some more work,
but does work in its current state.

As stated in previous posts, NFS and iSCSI survive service failures and
reconnect properly during heavy swapping.

Linus, when I mentioned swap over network to you in Ottawa, you said it was
a valid use case, that people actually do and want this. Can you agree with
the approach taken in these patches?

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
