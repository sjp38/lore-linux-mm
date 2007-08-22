Date: Wed, 22 Aug 2007 14:22:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.23-rc3-mm1 oom-killer gets invoked
Message-Id: <20070822142248.e9c04af2.akpm@linux-foundation.org>
In-Reply-To: <46CCA14A.6060103@linux.vnet.ibm.com>
References: <46CCA14A.6060103@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007 02:19:14 +0530
Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> I see the oom-killer getting invoked many times on the
> 2.6.23-rc3-mm1 kernel and have attached the complete console
> log and config file.
> 
> ========================================================
> cc1 invoked oom-killer: gfp_mask=0x280d2, order=0, oomkilladj=0
> 
>  [<c0147386>] out_of_memory+0x70/0xf6
> 
>  [<c01484c4>] <4>cc1 invoked oom-killer: gfp_mask=0x201d2, order=0, 
> oomkilladj=0
> 
>  [<c0147386>] out_of_memory+0x70/0xf6
> 
>  [<c01484c4>] __alloc_pages+0x21b/0x2a8
> 
>  [<c0173168>] mntput_no_expire+0x11/0x6e
> 
>  [<c0149f29>] __do_page_cache_readahead+0xc8/0x13a
> 
>  [<c014535b>] filemap_nopage+0x164/0x30d
> 
>  [<c0150c7d>] do_no_page+0x91/0x2fb
> 
>  [<c0151201>] __handle_mm_fault+0x151/0x2bc
> 
>  [<c016000f>] do_filp_open+0x25/0x39
> 
>  [<c0115990>] do_page_fault+0x2a3/0x5f7
> 
>  [<c01156ed>] do_page_fault+0x0/0x5f7
> 
>  [<c03336c4>] error_code+0x7c/0x84
> 
>  [<c0330000>] packet_rcv+0xfd/0x2d7
> 
>  =======================
> 
> DMA per-cpu:
> 
> CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 
> usd:   0
> 
> CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 
> usd:   0
> 
> CPU    2: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 
> usd:   0
> 
> CPU    3: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 
> usd:   0
> 
> Normal per-cpu:
> 
> CPU    0: Hot: hi:  186, btch:  31 usd:  67   Cold: hi:   62, btch:  15 
> usd:  57
> 
> CPU    1: Hot: hi:  186, btch:  31 usd: 170   Cold: hi:   62, btch:  15 
> usd:  57
> 
> CPU    2: Hot: hi:  186, btch:  31 usd: 126   Cold: hi:   62, btch:  15 
> usd:  50
> 
> CPU    3: Hot: hi:  186, btch:  31 usd:  50   Cold: hi:   62, btch:  15 
> usd:  19
> 
> HighMem per-cpu:
> 
> CPU    0: Hot: hi:  186, btch:  31 usd:  21   Cold: hi:   62, btch:  15 
> usd:  10
> 
> CPU    1: Hot: hi:  186, btch:  31 usd:  23   Cold: hi:   62, btch:  15 
> usd:  19
> 
> CPU    2: Hot: hi:  186, btch:  31 usd:   7   Cold: hi:   62, btch:  15 
> usd:  27
> 
> CPU    3: Hot: hi:  186, btch:  31 usd:  20   Cold: hi:   62, btch:  15 
> usd:  56
> 
> Active:228916 inactive:238880 dirty:0 writeback:0 unstable:0
> 
>  free:12273 slab:14578 mapped:36 pagetables:10564 bounce:0
> 
> DMA free:8076kB min:68kB low:84kB high:100kB active:2496kB 
> inactive:1716kB present:16224kB pages_scanned:171850 all_unreclaimable? yes
> 
> lowmem_reserve[]: 0 871 2011
> 
> Normal free:40400kB min:3740kB low:4672kB high:5608kB active:358456kB 
> inactive:358000kB present:892320kB pages_scanned:1427617 
> all_unreclaimable? yes
> 
> lowmem_reserve[]: 0 0 9123
> 
> HighMem free:616kB min:512kB low:1736kB high:2960kB active:554712kB 
> inactive:595804kB present:1167812kB pages_scanned:2215902 
> all_unreclaimable? yes
> 
> lowmem_reserve[]: 0 0 0
> 
> DMA: 1*4kB 1*8kB 2*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 
> 1*2048kB 1*4096kB = 8076kB
> 
> Normal: 70*4kB 25*8kB 1*16kB 1*32kB 1*64kB 33*128kB 7*256kB 0*512kB 
> 1*1024kB 0*2048kB 8*4096kB = 40400kB
> 
> HighMem: 49*4kB 20*8kB 4*16kB 6*32kB 1*64kB 0*128kB 0*256kB 0*512kB 
> 0*1024kB 0*2048kB 0*4096kB = 676kB
> 
> Swap cache: add 12954, delete 12954, find 2676/3551, race 0+1
> 
> Free swap  = 0kB
> 
> Total swap = 8024kB
> 
> Out of memory: kill process 27480 (make) score 2082 or a child

It's a bit harsh, sending 330kb emails to linux-kernel.  Please try to
strip these things down to the important information.  Also, it'd be nice
if you could find the source of those double-linefeeds and make it stop.


I don't know whwy the VM decided that you've run out of memory.  After the
oom-killing, does

echo 3 > /proc/sys/vm/drop_caches

make the numbers in /proc/meminfo change significantly?

Which filesystem was being used here?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
