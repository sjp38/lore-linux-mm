Message-Id: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:20 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 00/14] bootmem rewrite v2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

to your request I broke up this big diff into more reviewable smaller
chunks.  They apply to -mmotm (modulo the conflicts I ran into, but
they seemed unrelated).

So, here is another version of my attempt to cleanly rewrite the
bootmem allocator.  More details in the respective patch changelogs.

Compile- and runtime tested on x86 32bit UMA.

	Hannes

 arch/alpha/mm/numa.c     |    2 +-
 arch/arm/plat-omap/fb.c  |    4 +-
 arch/avr32/mm/init.c     |    3 +-
 arch/ia64/mm/discontig.c |   19 +-
 arch/m32r/mm/discontig.c |    3 +-
 arch/m32r/mm/init.c      |    4 +-
 arch/mn10300/mm/init.c   |    6 +-
 arch/sh/mm/init.c        |    2 +-
 include/linux/bootmem.h  |   82 ++--
 mm/bootmem.c             |  918 +++++++++++++++++++++++++---------------------
 10 files changed, 552 insertions(+), 491 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
