Date: Mon, 4 Feb 2008 22:27:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB patches in mm
In-Reply-To: <20080130164436.675b1267.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802042223200.6832@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801291947420.22779@schroedinger.engr.sgi.com>
 <20080130153222.e60442de.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0801301549360.1722@schroedinger.engr.sgi.com>
 <20080130164436.675b1267.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, matthew@wil.cx
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008, Andrew Morton wrote:

> So please send me the git URL when it suits you.

Git URL / branch is:

git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slub-mm

Current content is the basic cmpxchg framework that is needed later for 
the cpu_alloc/cpu_ops stuff and the statistics code.


The following changes since commit 
9ef9dc69d4167276c04590d67ee55de8380bc1ad:
  Linus Torvalds (1):
        Merge branch 'for-linus' of 
master.kernel.org:/home/rmk/linux-2.6-arm

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slub-mm

Christoph Lameter (3):
      SLUB: Use unique end pointer for each slab page.
      SLUB: Alternate fast paths using cmpxchg_local
      SLUB: Support for statistics to help analyze allocator behavior

 Documentation/vm/slabinfo.c |  149 +++++++++++++++++++++++--
 arch/x86/Kconfig            |    4 +
 include/linux/mm_types.h    |    5 +-
 include/linux/slub_def.h    |   23 ++++
 lib/Kconfig.debug           |   11 ++
 mm/slub.c                   |  257 
+++++++++++++++++++++++++++++++++++++------
 6 files changed, 405 insertions(+), 44 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
