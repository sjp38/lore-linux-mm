From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Remap_file_pages protection support: when to send patches?
Date: Mon, 5 Mar 2007 22:45:26 +0100
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200703052245.27260.blaisorblade@yahoo.it>
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, user-mode-linux-devel@lists.sourceforge.net, Ingo Molnar <mingo@redhat.com>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew, I've been resurrecting lately remap_file_pages protection support 
for UML.

I've updated it to 2.6.20 and it passes its unit test, and the 
resulting kernel has no stability problems in my experience on my Dual Core 
laptop (I've been using it for long time).

Since last time I sent it, I've fixed remaining problems and TODOs, and 
cleaned up the split (I'm just improving the way patches are split). Now it 
is a patchset with 13 patches, and the diffstat is attached.

Now I'm curious about when I should or could better send those patches - i.e. 
when they bring less noise into the -mm tree?

This would allow me to snapshot the git and/or -mm tree, test the patches 
against that kernel with my unit testing program, and only then send these 
patches to get them at least included into -mm.

Any suggestion? Obviously if you want to see the code first, in the standard 
way, I'll follow usual practice  - just tell it me (and I'll send it shortly 
anyway, if I get no answer).

Good bye

$ q diff --combine -|diffstat -p1
 arch/i386/mm/fault.c              |   10 +++
 arch/um/kernel/trap.c             |   10 ++-
 arch/x86_64/mm/fault.c            |   13 +++
 include/asm-alpha/mman.h          |    3
 include/asm-arm/mman.h            |    3
 include/asm-arm26/mman.h          |    3
 include/asm-cris/mman.h           |    3
 include/asm-frv/mman.h            |    3
 include/asm-generic/pgtable.h     |   13 +++
 include/asm-h8300/mman.h          |    3
 include/asm-i386/mman.h           |    3
 include/asm-i386/pgtable-2level.h |   11 +--
 include/asm-i386/pgtable-3level.h |    7 +-
 include/asm-i386/pgtable.h        |   24 +++++++
 include/asm-ia64/mman.h           |    3
 include/asm-m32r/mman.h           |    3
 include/asm-m68k/mman.h           |    3
 include/asm-mips/mman.h           |    3
 include/asm-parisc/mman.h         |    3
 include/asm-powerpc/mman.h        |    3
 include/asm-s390/mman.h           |    3
 include/asm-sh/mman.h             |    3
 include/asm-sparc/mman.h          |    3
 include/asm-sparc64/mman.h        |    3
 include/asm-um/pgtable-2level.h   |   16 +++-
 include/asm-um/pgtable-3level.h   |   21 ++++--
 include/asm-um/pgtable.h          |   21 ++++++
 include/asm-x86_64/mman.h         |    3
 include/asm-x86_64/pgtable.h      |   29 ++++++++
 include/asm-xtensa/mman.h         |    3
 include/linux/bitops.h            |   10 +++
 include/linux/mm.h                |   43 +++++++++++--
 include/linux/mman.h              |   25 ++-----
 include/linux/pagemap.h           |   22 ++++++
 mm/filemap.c                      |    2
 mm/fremap.c                       |  100 +++++++++++++++++++++---------
 mm/memory.c                       |  124 
++++++++++++++++++++++++++++++++------
 mm/mprotect.c                     |    7 ++
 mm/rmap.c                         |    3
 mm/shmem.c                        |    2
 40 files changed, 472 insertions(+), 98 deletions(-)

-- 
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
