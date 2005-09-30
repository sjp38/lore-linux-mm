From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 00/07][RFC] i386: NUMA emulation
Date: Fri, 30 Sep 2005 16:33:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

These patches implement NUMA memory node emulation for regular i386 PC:s.

NUMA emulation could be used to provide coarse-grained memory resource control
using CPUSETS. Another use is as a test environment for NUMA memory code or
CPUSETS using an i386 emulator such as QEMU.

A similar feature was accepted for x86_64 back in 2.6.9. These patches use the
same config options and kernel command line parameters as the x86_64 code.

Patches that depend on 2.6.14-rc2:

[PATCH 01/07] i386: srat non acpi
[PATCH 02/07] i386: numa on non-smp
[PATCH 03/07] cpuset: smp or numa

Patches that depend on 2.6.14-rc2 plus two patches written by Dave Hansen and 
posted to lkml and linux-mm at Sep 13 2005:

i386: consolidate discontig functions into normal ones
i386: move NUMA code into numa.c

[PATCH 04/07] i386: numa warning fix
[PATCH 05/07] i386: sparsemem on pc
[PATCH 06/07] i386: discontigmem on pc
[PATCH 07/07] i386: numa emulation on pc

To test, configure your i386 kernel with CONFIG_X86_PC, CONFIG_NUMA_EMU and 
CONFIG_NUMA all set and pass "numa=fake=2" to the kernel to emulate two nodes.

Feedback is very appreciated.

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
