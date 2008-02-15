Date: Thu, 14 Feb 2008 16:42:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [git pull] slab allocator fixes / cleanups
Message-ID: <Pine.LNX.4.64.0802141544130.3913@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following changes since commit e760e716d47b48caf98da348368fd41b4a9b9e7e:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../jejb/scsi-rc-fixes-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slab-linus

Adrian Bunk (1):
      make slub.c:slab_address() static

Christoph Lameter (3):
      slub: Determine gfpflags once and not every time a slab is allocated
      slub: Fallback to kmalloc_large for failing higher order allocs
      slub: Support 4k kmallocs again to compensate for page allocator slowness

Marcin Slusarz (1):
      slab: avoid double initialization & do initialization in 1 place

Pekka Enberg (1):
      slub: kmalloc page allocator pass-through cleanup

 include/linux/slub_def.h |   15 +++++--
 mm/slab.c                |    3 +-
 mm/slub.c                |   94 
+++++++++++++++++++++++++++++++---------------
 3 files changed, 75 insertions(+), 37 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
