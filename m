Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9DCD96B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 06:03:01 -0400 (EDT)
Received: by fxm24 with SMTP id 24so1557464fxm.38
        for <linux-mm@kvack.org>; Mon, 15 Jun 2009 03:03:03 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 15 Jun 2009 14:03:03 +0400
Message-ID: <a4423d670906150303o353f598dg4eb7b1f181344d8e@mail.gmail.com>
Subject: 2.6.31-rc1: memory initialization warnings on sparc
From: Alexander Beregalov <a.beregalov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

Kernel is 2.6.30-03984-g45e3e19
It is Ultra10 (UP) with 1Gb RAM

PROMLIB: Sun IEEE Boot Prom 'OBP 3.25.3 2000/06/29 14:12'
PROMLIB: Root node compatible:
Linux version 2.6.30-03984-g45e3e19 (alexb@sparky) (gcc version 4.3.3
(Gentoo 4.3.3 p1.0) ) #27 PREEMPT Mon Jun 15 13:42:41 MSD 2009
console [earlyprom0] enabled
ARCH: SUN4U
Ethernet address: 08:00:20:ff:e6:ff
Kernel: Using 4 locked TLB entries for main kernel image.
Remapping the kernel... done.
OF stdout device is: /pci@1f,0/pci@1,1/SUNW,m64B@2
PROM: Built device tree with 41922 bytes of memory.
Top of RAM: 0x3ff44000, Total RAM: 0x3ff34000
Memory hole size: 0MB
[0000000200000000-fffff80001400000] page_structs=131072 node=0 entry=0/0
[0000000200000000-fffff80001800000] page_structs=131072 node=0 entry=1/0
Allocated 1056768 bytes for kernel page tables.
Zone PFN ranges:
  Normal   0x00000000 -> 0x0001ffa2
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000000 -> 0x0001ff7f
    0: 0x0001ff80 -> 0x0001ff98
    0: 0x0001ff9f -> 0x0001ffa2
On node 0 totalpages: 130970
  Normal zone: 1024 pages used for memmap
  Normal zone: 0 pages reserved
  Normal zone: 129946 pages, LIFO batch:15
Booting Linux...
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129946
Kernel command line: root=/dev/sda2
PID hash table entries: 4096 (order: 12, 32768 bytes)
Dentry cache hash table entries: 131072 (order: 7, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 6, 524288 bytes)
------------[ cut here ]------------
WARNING: at kernel/lockdep.c:2282 lockdep_trace_alloc+0xd0/0xf8()
Modules linked in:
Call Trace:
 [0000000000450cf8] warn_slowpath_common+0x50/0x84
 [0000000000450d48] warn_slowpath_null+0x1c/0x2c
 [0000000000474148] lockdep_trace_alloc+0xd0/0xf8
 [000000000049149c] __alloc_pages_internal+0x30/0x434
 [00000000007dad60] mem_init+0x234/0x304
 [00000000007d6638] start_kernel+0x16c/0x30c
 [000000000066b14c] tlb_fixup_done+0x88/0x90
 [0000000000000000] (null)
---[ end trace 139ce121c98e96c9 ]---
Memory: 1023456k available (2536k kernel code, 1328k data, 144k init)
[fffff80000000000,000000003ff44000]
SLUB: Genslabs=14, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Preemptible RCU implementation.
NR_IRQS:255
------------[ cut here ]------------
WARNING: at mm/bootmem.c:535 alloc_arch_preferred_bootmem+0x34/0x64()
Modules linked in:
Call Trace:
 [0000000000450cf8] warn_slowpath_common+0x50/0x84
 [0000000000450d48] warn_slowpath_null+0x1c/0x2c
 [00000000007ddf9c] alloc_arch_preferred_bootmem+0x34/0x64
 [00000000007de75c] ___alloc_bootmem_nopanic+0x20/0xc0
 [00000000007de8d8] ___alloc_bootmem+0x10/0x44
 [00000000007dea8c] __alloc_bootmem+0x10/0x20
 [00000000007d7388] init_IRQ+0xcc/0x1d4
 [00000000007d6690] start_kernel+0x1c4/0x30c
 [000000000066b14c] tlb_fixup_done+0x88/0x90
 [0000000000000000] (null)
---[ end trace 139ce121c98e96ca ]---
clocksource: mult[245d1] shift[16]
clockevent: mult[70a3d70a] shift[32]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
