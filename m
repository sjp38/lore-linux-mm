Date: Mon, 25 Jul 2005 09:27:01 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Question about OOM-Killer
Message-ID: <20050725122701.GC5429@dmt.cnet>
References: <20050718122101.751125ef.washer@trlp.com> <20050718123650.01a49f31.washer@trlp.com> <20050723130048.GA16460@dmt.cnet> <20050725121130.5fed7286.washer@trlp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050725121130.5fed7286.washer@trlp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Washer <washer@trlp.com>, ak@muc.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 25, 2005 at 12:11:30PM -0700, James Washer wrote:
> Pretty typical message here...
> Jul  6 17:31:27 p6 kernel: oom-killer: gfp_mask=0xd1

__GFP_FS|__GFP_IO|__GFP_WAIT|__GFP_DMA

> Jul  6 17:31:27 p6 kernel: Node 0 DMA per-cpu:
> Jul  6 17:31:27 p6 kernel: cpu 0 hot: low 2, high 6, batch 1
> Jul  6 17:31:27 p6 kernel: cpu 0 cold: low 0, high 2, batch 1 
> Jul  6 17:31:27 p6 kernel: cpu 1 hot: low 2, high 6, batch 1
> Jul  6 17:31:27 p6 kernel: cpu 1 cold: low 0, high 2, batch 1 
> Jul  6 17:31:27 p6 kernel: Node 0 Normal per-cpu:
> Jul  6 17:31:27 p6 kernel: cpu 0 hot: low 32, high 96, batch 16
> Jul  6 17:31:27 p6 kernel: cpu 0 cold: low 0, high 32, batch 16
> Jul  6 17:31:27 p6 kernel: cpu 1 hot: low 32, high 96, batch 16
> Jul  6 17:31:27 p6 kernel: cpu 1 cold: low 0, high 32, batch 16
> Jul  6 17:31:27 p6 kernel: Node 0 HighMem per-cpu: empty
> Jul  6 17:31:27 p6 kernel: 
> Jul  6 17:31:31 p6 gconfd (washer-7174): SIGHUP received, reloading all databases
> Jul  6 17:31:37 p6 kernel: Free pages:       16236kB (0kB HighMem)
> Jul  6 17:31:38 p6 su(pam_unix)[16136]: session closed for user root
> Jul  6 17:31:49 p6 kernel: Active:596167 inactive:854867 dirty:624740 writeback:0 unstable:0 free:4059 slab:52688 mapped:595231 pagetables:4862
> Jul  6 17:32:02 p6 kernel: Node 0 DMA free:20kB min:24kB low:28kB high:36kB active:0kB inactive:0kB present:16384kB pages_scanned:1 all_unreclaimable? yes

Andi, 

Zone DMA is exhausted, filled with non-LRU pages, and some 
allocator is requesting a GFP_DMA page.

Can you enlight us what kind of devices are limited to <16MB 
on x86-64, and the reasoning for it ?

> Jul  6 17:32:06 p6 kernel: lowmem_reserve[]: 0 7152 7152
> Jul  6 17:32:11 p6 kernel: Node 0 Normal free:16216kB min:10808kB low:13508kB high:16212kB active:2384668kB inactive:3419468kB present:7323648kB pages_scanned:0 all_unreclaimable? no
> Jul  6 17:32:13 p6 kernel: lowmem_reserve[]: 0 0 0
> Jul  6 17:32:13 p6 kernel: Node 0 HighMem free:0kB min:128kB low:160kB high:192kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
> Jul  6 17:32:13 p6 kernel: lowmem_reserve[]: 0 0 0 
> Jul  6 17:32:13 p6 kernel: Node 0 DMA: 1*4kB 0*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20kB
> Jul  6 17:32:13 p6 kernel: Node 0 Normal: 34*4kB 192*8kB 53*16kB 92*32kB 2*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 1*2048kB 2*4096kB = 16216kB
> Jul  6 17:32:13 p6 kernel: Node 0 HighMem: empty
> Jul  6 17:32:13 p6 kernel: Swap cache: add 48, delete 48, find 0/0, race 0+0
> Jul  6 17:32:13 p6 kernel: Free swap  = 8385728kB
> Jul  6 17:32:13 p6 kernel: Total swap = 8385920kB
> Jul  6 17:32:13 p6 kernel: Out of Memory: Killed process 10475 (firefox-bin).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
