Message-Id: <20080130180940.022172000@sgi.com>
Date: Wed, 30 Jan 2008 10:09:40 -0800
From: travis@sgi.com
Subject: [PATCH 0/6] percpu: Per cpu code simplification linux-2.6.git
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, mingo@elte.hu, Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patchset to fixup differences between x86.git and base linux-2.6.git

This patchset simplifies the code that arches need to maintain to support
per cpu functionality. Most of the code is moved into arch independent
code. Only a minimal set of definitions is kept for each arch.

Based on latest linux-2.6.git

Cc: Andi Kleen <ak@suse.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: David Miller <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org

Signed-off-by: Mike Travis <travis@sgi.com>
---

Notes:

* The latest linux-2.6.git as the following errors unrelated to this patch,
which prevents a complete verification:

x86_64: allmodconfig | allyesconfig
drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict

ia64-sn2:
drivers/md/md.c:5881: error: __param_start_ro causes a section type conflict

s390-default:
include/linux/sched.h:1931: error: implicit declaration of function '__raw_spin_is_contended'

sparc-default:
include/asm/pgtable.h:346: error: expected '=', ',', ';', 'asm' or '__attribute__' before '___f___swp_entry'
include/asm/highmem.h:60: error: implicit declaration of function 'PageHighMem'
include/asm/highmem.h:61: error: implicit declaration of function 'page_address'

* Successful Builds:

	x86_64-default
	x86_64-single
	x86_64-8psmp
	x86_64-debug
	x86_64-numa
	i386-default
	i386-single
	i386-smp
	arm-default
	sparc64-default
	sparc64-smp
	ppc-pmac32
	ppc-smp

* Test Results:

x86_64 all configurations:

kernel BUG at /mdata/lwork/polaris1/travis/workareas/Linus/linux-2.6/drivers/ide/ide-cd.c:1726!
Pid: 1327, comm: udevd Not tainted 2.6.24-defconfig-04890-gdd430ca-dirty #1
Call Trace:
 <IRQ>  [<ffffffff804613ed>] ? cdrom_newpc_intr+0x0/0x2f3
 [<ffffffff80453edd>] ? ide_intr+0x193/0x207
 [<ffffffff80251c0c>] ? handle_IRQ_event+0x25/0x53
 [<ffffffff80253144>] ? handle_edge_irq+0xdd/0x11c
 [<ffffffff8020c1fc>] ? call_softirq+0x1c/0x28
 [<ffffffff8020e332>] ? do_IRQ+0xf1/0x15f
 [<ffffffff8020b581>] ? ret_from_intr+0x0/0xa
 <EOI>

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
