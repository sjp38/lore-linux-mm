Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B4C748D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:25:16 -0400 (EDT)
Date: Tue, 22 Mar 2011 21:25:11 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB fixes for v2.6.39-rc1
Message-ID: <alpine.DEB.2.00.1103222122150.5166@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

Here's a OOM path fix for lockless SLUB fastpath and a small debugging 
statistics improvement (both from Christoph).

                         Pekka

The following changes since commit f741a79e982cf56d7584435bad663553ffe6715f:
   Linus Torvalds (1):
         Merge branch 'for-linus' of git://git.kernel.org/.../mszeredi/fuse

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slab/urgent

Christoph Lameter (2):
       slub: Add missing irq restore for the OOM path
       slub: Add statistics for this_cmpxchg_double failures

  include/linux/slub_def.h |    1 +
  mm/slub.c                |    6 +++++-
  2 files changed, 6 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
