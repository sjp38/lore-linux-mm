From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051110090920.8083.54147.sendpatchset@cherry.local>
Subject: [PATCH 00/05][RFC] NUMA emulation update
Date: Thu, 10 Nov 2005 18:08:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, pj@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

CONFIG_NUMA_EMU - new and improved!

These patches update the current x86_64 NUMA emulation code by adding support
for dividing real NUMA nodes into several smaller emulated nodes. The good old
x86_64 implementation of NUMA emulation written by Andi Kleen has worked well
since 2.6.9, but it lacks support for dividing multiple real NUMA nodes.

The patches also break out the NUMA emulation code into some simple generic 
functions that could be used by several platforms. Only x86_64 gets modified
by this patch set, but I've planned to convert my i386 NUMA emulation code to
use these generic functions later on. I know that some kind of NUMA emulation
code also exists for ia64, and maybe it is possible to build that code on top
of the generic functions too.

Patches on top of 2.6.14-mm1:

[PATCH 01/05] NUMA: Generic code
[PATCH 02/05] x86_64: NUMA cleanup
[PATCH 03/05] x86_64: NUMA emulation
[PATCH 04/05] x86_64: NUMA without SMP
[PATCH 05/05] NUMA: find_next_best_node fix

About NUMA emulation:

NUMA emulation could be used to provide coarse-grained memory resource control
using CPUSETS. Another use is as a test environment for NUMA memory code or
CPUSETS using an system emulator such as QEMU.

Feedback is very appreciated.

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
