From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 25 Aug 2006 17:37:09 +0200
Message-Id: <20060825153709.24254.28118.sendpatchset@twins>
Subject: [PATCH 0/6] Swap over NFS
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

Hi,

These patches implement swap files on NFS, but lay the foundation to
allow swap files on any non block device backed file.

As is, these patches allow for swapfiles to me used on NFS mounts. However
some extra work is needed to make this safe. It is not very hard to deadlock
a kernel with only these patches.

In the next VM deadlock avoidance series I will include a patch to remedy
this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
