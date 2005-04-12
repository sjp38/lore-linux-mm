Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id j3CAgi0Q176704
	for <linux-mm@kvack.org>; Tue, 12 Apr 2005 10:42:44 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3CAgixU222290
	for <linux-mm@kvack.org>; Tue, 12 Apr 2005 12:42:44 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.12.11) with ESMTP id j3CAghJo007141
	for <linux-mm@kvack.org>; Tue, 12 Apr 2005 12:42:43 +0200
Received: from localhost (dyn-9-152-216-55.boeblingen.de.ibm.com [9.152.216.55])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.12.11) with ESMTP id j3CAghuV007134
	for <linux-mm@kvack.org>; Tue, 12 Apr 2005 12:42:43 +0200
Date: Tue, 12 Apr 2005 12:42:43 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: OOM-killer kills too early
Message-ID: <20050412104243.GA8278@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I think we ran into a situation where the OOM killer starts
killing processes while there is still plenty of swap space
left.
Scenario is the following:
Plain 2.6.12-rc2 on a 64 bit s390 z/VM guest with 4 cpus and
2 GB memory. In addition the system has 700 MB swap space on
disk.
The kernel has a module which allocated 1790MB of memory, thus
reducing the available memory for user space processes
significantly.
When I now run a process which is doing nothing but allocating
512 MB and writing something to each page so that the pages
actually really get allocated the OOM killer kills my process,
even if there is plenty of swap space left (see output below).

Shouldn't this process survive?

Thanks,
Heiko

oom-killer: gfp_mask=0x80d2
DMA per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
cpu 1 hot: low 32, high 96, batch 16
cpu 1 cold: low 0, high 32, batch 16
cpu 2 hot: low 32, high 96, batch 16
cpu 2 cold: low 0, high 32, batch 16
cpu 3 hot: low 32, high 96, batch 16
cpu 3 cold: low 0, high 32, batch 16
cpu 4 hot: low 32, high 96, batch 16
cpu 4 cold: low 0, high 32, batch 16
cpu 5 hot: low 32, high 96, batch 16
cpu 5 cold: low 0, high 32, batch 16
cpu 6 hot: low 32, high 96, batch 16
cpu 6 cold: low 0, high 32, batch 16
cpu 7 hot: low 32, high 96, batch 16
cpu 7 cold: low 0, high 32, batch 16
cpu 8 hot: low 32, high 96, batch 16
cpu 8 cold: low 0, high 32, batch 16
cpu 9 hot: low 32, high 96, batch 16
cpu 9 cold: low 0, high 32, batch 16
cpu 10 hot: low 32, high 96, batch 16
cpu 10 cold: low 0, high 32, batch 16
cpu 11 hot: low 32, high 96, batch 16
cpu 11 cold: low 0, high 32, batch 16
cpu 12 hot: low 32, high 96, batch 16
cpu 12 cold: low 0, high 32, batch 16
cpu 13 hot: low 32, high 96, batch 16
cpu 13 cold: low 0, high 32, batch 16
cpu 14 hot: low 32, high 96, batch 16
cpu 14 cold: low 0, high 32, batch 16
cpu 15 hot: low 32, high 96, batch 16
cpu 15 cold: low 0, high 32, batch 16
cpu 16 hot: low 32, high 96, batch 16
cpu 16 cold: low 0, high 32, batch 16
cpu 17 hot: low 32, high 96, batch 16
cpu 17 cold: low 0, high 32, batch 16
cpu 18 hot: low 32, high 96, batch 16
cpu 18 cold: low 0, high 32, batch 16
cpu 19 hot: low 32, high 96, batch 16
cpu 19 cold: low 0, high 32, batch 16
cpu 20 hot: low 32, high 96, batch 16
cpu 20 cold: low 0, high 32, batch 16
cpu 21 hot: low 32, high 96, batch 16
cpu 21 cold: low 0, high 32, batch 16
cpu 22 hot: low 32, high 96, batch 16
cpu 22 cold: low 0, high 32, batch 16
cpu 23 hot: low 32, high 96, batch 16
cpu 23 cold: low 0, high 32, batch 16
cpu 24 hot: low 32, high 96, batch 16
cpu 24 cold: low 0, high 32, batch 16
cpu 25 hot: low 32, high 96, batch 16
cpu 25 cold: low 0, high 32, batch 16
cpu 26 hot: low 32, high 96, batch 16
cpu 26 cold: low 0, high 32, batch 16
cpu 27 hot: low 32, high 96, batch 16
cpu 27 cold: low 0, high 32, batch 16
cpu 28 hot: low 32, high 96, batch 16
cpu 28 cold: low 0, high 32, batch 16
cpu 29 hot: low 32, high 96, batch 16
cpu 29 cold: low 0, high 32, batch 16
cpu 30 hot: low 32, high 96, batch 16
cpu 30 cold: low 0, high 32, batch 16
cpu 31 hot: low 32, high 96, batch 16
cpu 31 cold: low 0, high 32, batch 16
Normal per-cpu: empty
HighMem per-cpu: empty

Free pages:        5544kB (0kB HighMem)
Active:16038 inactive:30542 dirty:0 writeback:2809 unstable:0 free:1386 slab:2099 mapped:43531 pagetables:192
DMA free:5544kB min:5792kB low:7240kB high:8688kB active:64152kB inactive:122168kB present:2097152kB pages_scanned:49210 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Normal free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
HighMem free:0kB min:128kB low:160kB high:192kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 0*16kB 1*32kB 0*64kB 1*128kB 3*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 5544kB
Normal: empty
HighMem: empty
Swap cache: add 32685, delete 29628, find 11/12, race 0+0
Free swap  = 586036kB
Total swap = 716776kB
Out of Memory: Killed process 904 (a.out).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
