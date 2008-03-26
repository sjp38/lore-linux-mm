Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QL795v009431
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:07:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QL8Zdw181448
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:08:35 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QL8YTT011833
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:08:35 -0600
Subject: Re: [PATCH 0/3 (RFC)](memory hotplug) freeing pages allocated by
	bootmem for hotremove
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080322090539.2B1B.E1E9C6FF@jp.fujitsu.com>
References: <20080314231112.20D7.E1E9C6FF@jp.fujitsu.com>
	 <1206119137.8476.1.camel@dyn9047017100.beaverton.ibm.com>
	 <20080322090539.2B1B.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 26 Mar 2008 14:08:59 -0800
Message-Id: <1206569339.31756.0.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-03-22 at 09:09 +0900, Yasunori Goto wrote:
> > 
> > Do you have any updates to this. I am getting following boot panic while
> > testing this. Before I debug it, I want to make sure its not already 
> > fixed. Please let me know.
> 
> Hmmmm. No, I don't. Could you debug it?
> This may come from powerpc environment.
> 
> Thanks.
> 
> 
> > 
> > Thanks,
> > Badari
> > 
> > Linux version 2.6.25-rc5-mm1 (root@elm3b155) (gcc version 3.3.3 (SuSE Linux)) #2 SMP Fri Mar 21 07:48:29 PST 2008
> > [boot]0012 Setup Arch
> > NUMA associativity depth for CPU/Memory: 3
> > adding cpu 0 to node 0
> > node 0
> > NODE_DATA() = c000000071fea100
> > start_paddr = 0
> > end_paddr = 72000000
> > bootmap_paddr = 71fdb000
> > reserve_bootmem 0 7cc000
> > reserve_bootmem 23d0000 10000
> > reserve_bootmem 77b6000 84a000
> > reserve_bootmem 71fdb000 f000
> > reserve_bootmem 71fea100 1e00
> > reserve_bootmem 71febf68 14098
> > PCI host bridge /pci@800000020000002  ranges:
> >   IO 0x000003fe00200000..0x000003fe002fffff -> 0x0000000000000000
> >  MEM 0x0000040080000000..0x00000400bfffffff -> 0x00000000c0000000
> > PCI host bridge /pci@800000020000003  ranges:
> >   IO 0x000003fe00700000..0x000003fe007fffff -> 0x0000000000000000
> >  MEM 0x00000401c0000000..0x00000401ffffffff -> 0x00000000c0000000
> > EEH: PCI Enhanced I/O Error Handling Enabled
> > PPC64 nvram contains 7168 bytes
> > Zone PFN ranges:
> >   DMA             0 ->   466944
> >   Normal     466944 ->   466944
> > Movable zone start PFN for each node
> >   Node 0: 262144
> > early_node_map[1] active PFN ranges
> >     0:        0 ->   466944
> > [boot]0015 Setup Done
> > Built 1 zonelists in Node order, mobility grouping on.  Total pages: 451440
> > Policy zone: DMA
> > Kernel command line: root=/dev/sda3 selinux=0 elevator=cfq numa=debug kernelcore=1024M
> > [boot]0020 XICS Init
> > [boot]0021 XICS Done
> > PID hash table entries: 4096 (order: 12, 32768 bytes)
> > clocksource: timebase mult[1352e86] shift[22] registered
> > Console: colour dummy device 80x25
> > console handover: boot [udbg-1] -> real [hvc0]
> > Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
> > Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
> > freeing bootmem node 0
> > Unable to handle kernel paging request for data at address 0xcf7f80000000000c
> > Faulting instruction address: 0xc0000000000ce3e8
> > Oops: Kernel access of bad area, sig: 11 [#1]
> > SMP NR_CPUS=32 NUMA pSeries
> > Modules linked in:
> > NIP: c0000000000ce3e8 LR: c0000000000cf714 CTR: 800000000013f270
> > REGS: c0000000007639f0 TRAP: 0300   Not tainted  (2.6.25-rc5-mm1)
> > MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44002022  XER: 00000008
> > DAR: cf7f80000000000c, DSISR: 0000000042010000
> > TASK = c000000000689910[0] 'swapper' THREAD: c000000000760000 CPU: 0
> > GPR00: fffffffffffffffd c000000000763c70 c000000000761be0 0000000000000000
> > GPR04: cf7f800000000000 0000000000000000 0000000000000000 0000000000000001
> > GPR08: 0000000000000000 fffffffffffffffe 0000000000000088 cf00000000000000
> > GPR12: 0000000000004000 c00000000068a380 0000000000000000 0000000000000000
> > GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> > GPR20: 4000000001c00000 0000000000000000 0000000002241ed8 0000000000000000
> > GPR24: 0000000002242148 0000000000000000 c000000071feb000 0000000000000000
> > GPR28: c000000071feb000 0000000000000001 c0000000006e2bd8 cf7f800000000000
> > NIP [c0000000000ce3e8] .set_page_bootmem_info+0x10/0x38
> > LR [c0000000000cf714] .register_page_bootmem_info_section+0xc4/0x17c
> > Call Trace:
> > [c000000000763c70] [000000000000001a] 0x1a (unreliable)
> > [c000000000763d10] [c0000000000cf8f0] .register_page_bootmem_info_node+0x124/0x158
> > [c000000000763dc0] [c0000000006290e4] .free_all_bootmem_node+0x1c/0x3c
> > [c000000000763e50] [c00000000061d618] .mem_init+0xbc/0x260
> > [c000000000763ee0] [c00000000060bbcc] .start_kernel+0x2f4/0x3f4
> > [c000000000763f90] [c000000000008594] .start_here_common+0x54/0xc0
> > Instruction dump:
> > eb61ffd8 eb81ffe0 eba1ffe8 7c0803a6 ebc1fff0 ebe1fff8 7d808120 4e800020
> > 2fa50000 3920fffe 3800fffd 409e000c <9124000c> 48000008 9004000c 38000800
> > ---[ end trace 31fd0ba7d8756001 ]---
> > Kernel panic - not syncing: Attempted to kill the idle task!

Okay, its an issue with CONFIG_SPARSEMEM_VMEMMAP=y

I disabled it for now.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
