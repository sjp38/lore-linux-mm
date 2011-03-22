Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6AD838D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 10:40:22 -0400 (EDT)
Date: Tue, 22 Mar 2011 16:40:15 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <alpine.DEB.2.00.1103221635400.4521@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

Here's SLAB updates for 2.6.39-rc1. The interesting bits are SLUB lockless 
fastpath patches from Christoph which improve performance and updates to 
support bigger 'struct rcu_head' from Lai. I pulled the per-CPU tree to 
slub/lockless which is why some already merged patches show up in the 
pull request.

                         Pekka

The following changes since commit a952baa034ae7c2e4a66932005cbc7ebbccfe28d:
   Linus Torvalds (1):
         Merge branch 'for-linus' of git://git.kernel.org/.../dtor/input

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Christoph Lameter (5):
       mm: Remove support for kmem_cache_name()
       slub: min_partial needs to be in first cacheline
       slub: Get rid of slab_free_hook_irq()
       Lockless (and preemptless) fastpaths for slub
       slub: Dont define useless label in the !CONFIG_CMPXCHG_LOCAL case

Eric Dumazet (1):
       slub: fix kmemcheck calls to match ksize() hints

Lai Jiangshan (3):
       slub: automatically reserve bytes at the end of slab
       slub,rcu: don't assume the size of struct rcu_head
       slab,rcu: don't assume the size of struct rcu_head

Mariusz Kozlowski (1):
       slub: fix ksize() build error

Pekka Enberg (6):
       Revert "slab: Fix missing DEBUG_SLAB last user"
       Merge branch 'for-2.6.39' of git://git.kernel.org/.../tj/percpu into slub/lockless
       Merge branch 'slab/rcu' into slab/next
       Merge branch 'slab/urgent' into slab/next
       Merge branch 'slab/next' into for-linus
       Merge branch 'slub/lockless' into for-linus

  arch/alpha/kernel/vmlinux.lds.S    |    5 +-
  arch/arm/kernel/vmlinux.lds.S      |    2 +-
  arch/blackfin/kernel/vmlinux.lds.S |    2 +-
  arch/cris/kernel/vmlinux.lds.S     |    2 +-
  arch/frv/kernel/vmlinux.lds.S      |    2 +-
  arch/ia64/kernel/vmlinux.lds.S     |    2 +-
  arch/m32r/kernel/vmlinux.lds.S     |    2 +-
  arch/mips/kernel/vmlinux.lds.S     |    2 +-
  arch/mn10300/kernel/vmlinux.lds.S  |    2 +-
  arch/parisc/kernel/vmlinux.lds.S   |    2 +-
  arch/powerpc/kernel/vmlinux.lds.S  |    2 +-
  arch/s390/kernel/vmlinux.lds.S     |    2 +-
  arch/sh/kernel/vmlinux.lds.S       |    2 +-
  arch/sparc/kernel/vmlinux.lds.S    |    2 +-
  arch/tile/kernel/vmlinux.lds.S     |    2 +-
  arch/um/include/asm/common.lds.S   |    2 +-
  arch/x86/include/asm/percpu.h      |   48 +++++
  arch/x86/kernel/vmlinux.lds.S      |    4 +-
  arch/x86/lib/Makefile              |    1 +
  arch/x86/lib/cmpxchg16b_emu.S      |   59 ++++++
  arch/xtensa/kernel/vmlinux.lds.S   |    2 +-
  include/asm-generic/vmlinux.lds.h  |   35 +++--
  include/linux/percpu.h             |  128 +++++++++++++
  include/linux/slab.h               |    1 -
  include/linux/slub_def.h           |    8 +-
  mm/slab.c                          |   55 +++---
  mm/slob.c                          |    6 -
  mm/slub.c                          |  366 +++++++++++++++++++++++++++++-------
  28 files changed, 612 insertions(+), 136 deletions(-)
  create mode 100644 arch/x86/lib/cmpxchg16b_emu.S

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
