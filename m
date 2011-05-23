Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 133376B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 12:56:28 -0400 (EDT)
Date: Mon, 23 May 2011 19:56:23 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB updates for v2.6.40-rc0
Message-ID: <alpine.DEB.2.00.1105231955400.8359@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com

Hi Linus,

Here's bunch of fixes and cleanups to the SLUB allocator. Bulk of them are
related to the lockless fastpaths but there's also some preparational work on
lockless slowpaths that will hopefully appear in v2.6.41.

                         Pekka

The following changes since commit caebc160ce3f76761cc62ad96ef6d6f30f54e3dd:
   Linus Torvalds (1):
         Merge branch 'for-linus' of git://git.kernel.org/.../ryusuke/nilfs2

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Christoph Lameter (10):
       slub: Use NUMA_NO_NODE in get_partial
       slub: get_map() function to establish map of free objects in a slab
       slub: Eliminate repeated use of c->page through a new page variable
       slub: Move node determination out of hotpath
       slub: Move debug handlign in __slab_free
       slub: Remove CONFIG_CMPXCHG_LOCAL ifdeffery
       slub: Avoid warning for !CONFIG_SLUB_DEBUG
       slub: Make CONFIG_DEBUG_PAGE_ALLOC work with new fastpath
       slub: Remove node check in slab_free
       slub: Deal with hyperthetical case of PAGE_SIZE > 2M

David Rientjes (1):
       slub: avoid label inside conditional

Li Zefan (1):
       slub: Fix a typo in config name

Pekka Enberg (1):
       Merge branch 'slab/next' into for-linus

  include/linux/slub_def.h |    8 +-
  mm/slub.c                |  165 ++++++++++++++++++----------------------------
  2 files changed, 69 insertions(+), 104 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
