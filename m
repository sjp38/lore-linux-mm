Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E205C6B0088
	for <linux-mm@kvack.org>; Sun,  9 Jan 2011 04:13:33 -0500 (EST)
Date: Sun, 9 Jan 2011 11:13:29 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB changes for v2.6.38
Message-ID: <alpine.DEB.2.00.1101091110520.5270@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

It's been rather quiet for slab allocators this merge cycle. There's only 
few cleanups here. The bug fixes were merged in v2.6.37 already. As they 
were cherry-picked from this branch, they show up in the pull request 
(what's up with that btw).

                         Pekka

The following changes since commit 0c21e3aaf6ae85bee804a325aa29c325209180fd:
   Linus Torvalds (1):
         Merge branch 'for-next' of git://git.kernel.org/.../hch/hfsplus

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Christoph Lameter (1):
       slub: move slabinfo.c to tools/slub/slabinfo.c

Pavel Emelyanov (1):
       slub: Fix slub_lock down/up imbalance

Pekka Enberg (2):
       slub: Fix build breakage in Documentation/vm
       Merge branch 'slab/next' into for-linus

Richard Kennedy (1):
       slub tracing: move trace calls out of always inlined functions to reduce kernel code size

Steven Rostedt (1):
       tracing/slab: Move kmalloc tracepoint out of inline code

Tero Roponen (1):
       slub: Fix a crash during slabinfo -v

  Documentation/vm/Makefile                   |    2 +-
  include/linux/slab_def.h                    |   33 ++++++----------
  include/linux/slub_def.h                    |   55 +++++++++++++--------------
  mm/slab.c                                   |   38 +++++++++++-------
  mm/slub.c                                   |   30 +++++++++++---
  {Documentation/vm => tools/slub}/slabinfo.c |    6 +-
  6 files changed, 89 insertions(+), 75 deletions(-)
  rename {Documentation/vm => tools/slub}/slabinfo.c (99%)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
