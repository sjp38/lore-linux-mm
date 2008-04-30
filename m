Message-Id: <20080430170521.246745395@symbol.fehenstaub.lan>
Date: Wed, 30 Apr 2008 19:05:21 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch 0/4] Bootmem cleanups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ingo,

I now dropped the node-crossing patches from my bootmem series and
here is what is left over.

They apply to Linus' current git
(0ff5ce7f30b45cc2014cec465c0e96c16877116e).

Please note that all parts affecting !X86_32_BORING_UMA_BOX are untested!

 arch/alpha/mm/numa.c             |    8 ++--
 arch/arm/mm/discontig.c          |   34 ++++++++++-----------
 arch/ia64/mm/discontig.c         |   11 +++----
 arch/m32r/mm/discontig.c         |    4 +--
 arch/m68k/mm/init.c              |    4 +--
 arch/mips/sgi-ip27/ip27-memory.c |    3 +-
 arch/parisc/mm/init.c            |    3 +-
 arch/powerpc/mm/numa.c           |    3 +-
 arch/sh/mm/numa.c                |    5 +--
 arch/sparc64/mm/init.c           |    3 +-
 arch/x86/mm/discontig_32.c       |    3 +-
 arch/x86/mm/numa_64.c            |    6 +---
 include/linux/bootmem.h          |    7 +---
 mm/bootmem.c                     |   59 ++++++++++++++++++-------------------
 mm/page_alloc.c                  |    4 +--
 15 files changed, 67 insertions(+), 90 deletions(-)

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
