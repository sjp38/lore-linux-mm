Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0B916B0237
	for <linux-mm@kvack.org>; Wed,  5 May 2010 14:15:36 -0400 (EDT)
Date: Wed, 5 May 2010 21:15:32 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [GIT PULL] SLAB fixes for 2.6.34-rc7
Message-ID: <alpine.DEB.2.00.1005052113520.4496@melkki.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Here's a last minute SLUB fix from Yanmin Zhang. The fix itself has been 
cooking in linux-next for over a month but I think we want it in final 
release because it's really a regression introduced by the new per-CPU 
allocator changes.

                         Pekka

The following changes since commit 8777c793d6a24c7f3adf52b1b1086e9706de4589:
   Linus Torvalds (1):
         Merge branch 'for-linus' of git://git.kernel.org/.../tj/wq

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slab-for-linus

Zhang, Yanmin (1):
       slub: Fix bad boundary check in init_kmem_cache_nodes()

  mm/slub.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
