Date: Thu, 7 Feb 2008 18:13:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [git pull] more SLUB updates for 2.6.25
Message-ID: <Pine.LNX.4.64.0802071755580.7473@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slub-linus

(includes the cmpxchg_local fastpath since the cmpxchg_local work
by Matheiu is in now, and the non atomic unlock by Nick. Verified that 
this is not doing any harm after some other patches had been removed. 
cmpxchg_local fastpath was stripped of support for CONFIG_PREEMPT since
that uglified the code and did not seem to work right. We will be 
able to handle preempt much better in the future with some upcoming 
patches)

Christoph Lameter (4):
      SLUB: Deal with annoying gcc warning on kfree()
      SLUB: Use unique end pointer for each slab page.
      SLUB: Alternate fast paths using cmpxchg_local
      SLUB: Support for performance statistics

Ingo Molnar (1):
      SLUB: fix checkpatch warnings

Nick Piggin (1):
      Use non atomic unlock

 Documentation/vm/slabinfo.c |  149 ++++++++++++++++++--
 arch/x86/Kconfig            |    4 +
 include/linux/mm_types.h    |    5 +-
 include/linux/slub_def.h    |   23 +++
 lib/Kconfig.debug           |   13 ++
 mm/slub.c                   |  326 
++++++++++++++++++++++++++++++++++++-------
 6 files changed, 457 insertions(+), 63 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
