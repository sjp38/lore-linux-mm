Message-Id: <20080416113629.947746497@skyscraper.fehenstaub.lan>
Date: Wed, 16 Apr 2008 13:36:29 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC][patch 0/5] Bootmem fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

here are a bunch of fixes for the bootmem allocator.  These are tested
on boring x86_32 UMA hardware, but 3 patches only show their effects
on multi-node systems, so please review and test.

Only the first two patches are real code changes, the others are
cleanups.

`Node-setup agnostic free_bootmem()' assumes that all bootmem
descriptors describe contiguous regions and bdata_list is in ascending
order.  Yinghai was unsure about this fact, Ingo could you ACK/NAK
this?

	Hannes

 arch/alpha/mm/numa.c             |    8 ++--
 arch/arm/mm/discontig.c          |   34 +++++++--------
 arch/ia64/mm/discontig.c         |   11 ++---
 arch/m32r/mm/discontig.c         |    4 +-
 arch/m68k/mm/init.c              |    4 +-
 arch/mips/sgi-ip27/ip27-memory.c |    3 +-
 arch/parisc/mm/init.c            |    3 +-
 arch/powerpc/mm/numa.c           |    3 +-
 arch/sh/mm/numa.c                |    5 +-
 arch/x86/mm/discontig_32.c       |    3 +-
 arch/x86/mm/numa_64.c            |    4 +-
 include/linux/bootmem.h          |    7 +--
 mm/bootmem.c                     |   82 ++++++++++++++++++++++----------------
 mm/page_alloc.c                  |    4 +-
 14 files changed, 84 insertions(+), 91 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
