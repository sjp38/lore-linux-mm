Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 7AAF76B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 03:02:08 -0400 (EDT)
Message-ID: <5009038A.4090001@cn.fujitsu.com>
Date: Fri, 20 Jul 2012 15:06:50 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 0/8] memory-hotplug : hot-remove physical memory(clear
 page table)
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

This patch series aims to support physical memory hot-remove(clear page table).

This patch series base on ishimatsu's patch series. You can get it here:
http://www.spinics.net/lists/linux-acpi/msg36804.html

The patches can remove following things:
  - page table of removed memory

If you find lack of function for physical memory hot-remove, please let me
know.

Note:
* The patch "remove memory info from list before freeing it" is being disccussed
  in other thread. But for testing the patch series, the patch is needed.
  So I added the patch as [PATCH 0/8].
* You need to apply ishimatsu's patch series first before applying this patch
  series.

Wen Congyang (8):
  memory-hotplug: store the node id in acpi_memory_device
  memory-hotplug: offline memory only when it is onlined
  memory-hotplug: call remove_memory() to cleanup when removing memory
    device
  memory-hotplug: export the function acpi_bus_remove()
  memory-hotplug: call acpi_bus_remove() to remove memory device
  memory-hotplug: introduce new function arch_remove_memory()
  x86: make __split_large_page() generally avialable
  memory-hotplug: implement arch_remove_memory()

 arch/ia64/mm/init.c                  |   16 ++++
 arch/powerpc/mm/mem.c                |   14 +++
 arch/s390/mm/init.c                  |    8 ++
 arch/sh/mm/init.c                    |   15 +++
 arch/tile/mm/init.c                  |    8 ++
 arch/x86/include/asm/pgtable_types.h |    1 +
 arch/x86/mm/init_32.c                |   10 ++
 arch/x86/mm/init_64.c                |  160 ++++++++++++++++++++++++++++++++++
 arch/x86/mm/pageattr.c               |   47 +++++-----
 drivers/acpi/acpi_memhotplug.c       |   24 ++++--
 drivers/acpi/scan.c                  |    3 +-
 include/acpi/acpi_bus.h              |    1 +
 include/linux/memory_hotplug.h       |    1 +
 mm/memory_hotplug.c                  |    2 +-
 14 files changed, 280 insertions(+), 30 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
