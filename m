Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EFAB56B01BD
	for <linux-mm@kvack.org>; Sun, 30 May 2010 15:36:51 -0400 (EDT)
Date: Sun, 30 May 2010 22:36:47 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [GIT PULL] SLAB fixes for 2.6.35-rc0
Message-ID: <alpine.DEB.2.00.1005302235290.22112@melkki.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Here's few regression fixes to SLUB. The S390 regression was introduced in 
.33 and the hackbench performance regression in .34.

                         Pekka

The following changes since commit 24010e460454ec0d2f4f0213b667b4349cbdb8e1:
   Linus Torvalds (1):
         Merge branch 'drm-linus' of git://git.kernel.org/.../airlied/drm-2.6

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slub/urgent

Alexander Duyck (1):
       slub: move kmem_cache_node into it's own cacheline

Christoph Lameter (1):
       SLUB: Allow full duplication of kmalloc array for 390

  include/linux/slub_def.h |   11 ++++-------
  mm/slub.c                |   33 +++++++++++----------------------
  2 files changed, 15 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
