From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 00/21] Generic show_mem()
Date: Wed,  2 Apr 2008 22:29:52 +0200
Message-ID: <12071682142640-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759480AbYDBVbg@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

Hi.

Every arch implements its own show_mem() function.  Most of them share
quite some code, some of them are completely identical.

This proposal implements a generic version of this functions and
migrates almost all architectures to use it.

I have only tested the x86_32 related part in lack of other archs.

As far as I understood the code, the generic version should work for
the architectures that used to iterate mem_map pfns, but I can not
tell for sure.  Please give feedback.

Also, this series leaves ia64, arm, and sparc as is.

Tony, as far as I understand, ia64 jumps holes in the memory map with
vmemmap_find_next_valid_pfn().  Any idea if and how this could be
built into the generic show_mem() version?

Russell, I don't know if arm can be transformed.  For now, it keeps
its arch-specific show_mem().

Dave, can sparc's version be simply migrated as well?

	Hannes

 arch/alpha/mm/init.c      |   30 ------------------
 arch/alpha/mm/numa.c      |   35 ----------------------
 arch/arm/mm/Kconfig       |    3 ++
 arch/avr32/mm/init.c      |   39 ------------------------
 arch/blackfin/mm/init.c   |   27 -----------------
 arch/cris/mm/init.c       |   31 -------------------
 arch/frv/mm/init.c        |   31 -------------------
 arch/h8300/mm/init.c      |   28 -----------------
 arch/ia64/Kconfig         |    3 ++
 arch/m32r/mm/init.c       |   37 -----------------------
 arch/m68k/mm/init.c       |   31 -------------------
 arch/m68knommu/mm/init.c  |   28 -----------------
 arch/mips/mm/Makefile     |    3 +-
 arch/mips/mm/pgtable.c    |   37 -----------------------
 arch/mn10300/mm/pgtable.c |   27 -----------------
 arch/parisc/mm/init.c     |   72 ---------------------------------------------
 arch/powerpc/mm/mem.c     |   40 -------------------------
 arch/ppc/mm/init.c        |   31 -------------------
 arch/s390/mm/init.c       |   36 ----------------------
 arch/sh/mm/init.c         |   41 -------------------------
 arch/sparc/Kconfig        |    3 ++
 arch/sparc64/mm/init.c    |   45 ----------------------------
 arch/um/kernel/mem.c      |   31 -------------------
 arch/v850/kernel/setup.c  |   30 ------------------
 arch/x86/mm/init_64.c     |   40 -------------------------
 arch/x86/mm/pgtable_32.c  |   48 ------------------------------
 arch/xtensa/mm/init.c     |   27 -----------------
 mm/page_alloc.c           |   53 +++++++++++++++++++++++++++++++++
 28 files changed, 63 insertions(+), 824 deletions(-)
