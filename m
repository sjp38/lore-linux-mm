Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7QBBkEd000412
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 16:41:46 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7QBBkJG1413300
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 16:41:46 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7QBBklE028263
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 16:41:46 +0530
Message-ID: <48B3E4CC.9060309@linux.vnet.ibm.com>
Date: Tue, 26 Aug 2008 16:41:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de>
In-Reply-To: <48B296C3.6030706@iplabs.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Nietz <m.nietz-mm@iplabs.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marco Nietz wrote:
> Today, i've meet the oom-killer the first time, but i could not
> understand why this happens.
> 
> Swap and Highmem is ok, Could this be a Problem of lowmem and the bigmen
>  (pae) Kernel ?
> 
> It's a Machine with 2x4 Xeon Cores and 16GB of physical Memory running
> Debian Etch with Kernel 2.6.18-6-686-bigmem.
> 
> Hier the dmesg-Output
> 
> oom-killer: gfp_mask=0x84d0, order=0
>  [<c014290b>] out_of_memory+0x25/0x13a
>  [<c0143d74>] __alloc_pages+0x1f5/0x275
>  [<c014a439>] __pte_alloc+0x11/0x9e
>  [<c014b864>] copy_page_range+0x155/0x3da
>  [<c01ba1d8>] vsnprintf+0x419/0x457
>  [<c011c184>] copy_process+0xa73/0x10a9
>  [<c011ca1f>] do_fork+0x91/0x17a
>  [<c0124d67>] do_gettimeofday+0x31/0xce
>  [<c01012c2>] sys_clone+0x28/0x2d
>  [<c0102c0d>] sysenter_past_esp+0x56/0x79
> Mem-info:
> DMA per-cpu:
> cpu 0 hot: high 0, batch 1 used:0
> cpu 0 cold: high 0, batch 1 used:0
> cpu 1 hot: high 0, batch 1 used:0
> cpu 1 cold: high 0, batch 1 used:0
> cpu 2 hot: high 0, batch 1 used:0
> cpu 2 cold: high 0, batch 1 used:0
> cpu 3 hot: high 0, batch 1 used:0
> cpu 3 cold: high 0, batch 1 used:0
> cpu 4 hot: high 0, batch 1 used:0
> cpu 4 cold: high 0, batch 1 used:0
> cpu 5 hot: high 0, batch 1 used:0
> cpu 5 cold: high 0, batch 1 used:0
> cpu 6 hot: high 0, batch 1 used:0
> cpu 6 cold: high 0, batch 1 used:0
> cpu 7 hot: high 0, batch 1 used:0
> cpu 7 cold: high 0, batch 1 used:0
> DMA32 per-cpu: empty
> Normal per-cpu:
> cpu 0 hot: high 186, batch 31 used:128
> cpu 0 cold: high 62, batch 15 used:48
> cpu 1 hot: high 186, batch 31 used:30
> cpu 1 cold: high 62, batch 15 used:47
> cpu 2 hot: high 186, batch 31 used:35
> cpu 2 cold: high 62, batch 15 used:59
> cpu 3 hot: high 186, batch 31 used:79
> cpu 3 cold: high 62, batch 15 used:55
> cpu 4 hot: high 186, batch 31 used:8
> cpu 4 cold: high 62, batch 15 used:53
> cpu 5 hot: high 186, batch 31 used:162
> cpu 5 cold: high 62, batch 15 used:52
> cpu 6 hot: high 186, batch 31 used:181
> cpu 6 cold: high 62, batch 15 used:57
> cpu 7 hot: high 186, batch 31 used:9
> cpu 7 cold: high 62, batch 15 used:58
> HighMem per-cpu:
> cpu 0 hot: high 186, batch 31 used:18
> cpu 0 cold: high 62, batch 15 used:9
> cpu 1 hot: high 186, batch 31 used:47
> cpu 1 cold: high 62, batch 15 used:1
> cpu 2 hot: high 186, batch 31 used:102
> cpu 2 cold: high 62, batch 15 used:7
> cpu 3 hot: high 186, batch 31 used:171
> cpu 3 cold: high 62, batch 15 used:7
> cpu 4 hot: high 186, batch 31 used:172
> cpu 4 cold: high 62, batch 15 used:14
> cpu 5 hot: high 186, batch 31 used:26
> cpu 5 cold: high 62, batch 15 used:14
> cpu 6 hot: high 186, batch 31 used:29
> cpu 6 cold: high 62, batch 15 used:2
> cpu 7 hot: high 186, batch 31 used:99
> cpu 7 cold: high 62, batch 15 used:3
> Free pages:     5949076kB (5941820kB HighMem)
> Active:1102100 inactive:1373666 dirty:4831 writeback:0 unstable:0
> free:1487269 slab:35543 mapped:139487 pagetables:152485
> DMA free:3592kB min:68kB low:84kB high:100kB active:24kB inactive:16kB
> present:16384kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 880 17392

pages_scanned is 0

> DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB
> present:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 880 17392

pages_scanned is 0

> Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB
> inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
> lowmem_reserve[]: 0 0 0 132096

pages_scanned is 593 and all_unreclaimable is yes


> HighMem free:5941820kB min:512kB low:18148kB high:35784kB
> active:4408096kB inactive:5494404kB present:16908288kB pages_scanned:0
> all_unreclaimable? no

pages_scanned is 0

Do you have CONFIG_HIGHPTE set? I suspect you don't (I don't really know the
debian etch configuration). I suspect you've run out of zone normal pages to
allocate.

[snip]

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
