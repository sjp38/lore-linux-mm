Message-ID: <3963F5AB.AE456258@sun.com>
Date: Wed, 05 Jul 2000 19:57:47 -0700
From: ludovic fernandez <ludovic.fernandez@sun.com>
MIME-Version: 1.0
Subject: Re: PATCH: vm/kswapd in linux-2.4.0-test2
References: <39627B27.24266363@sun.com> <20000705225334.A6893@fred.muc.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello Andi,

Thanks for trying this patch....but I still believe it needs some tunings.
I will be really interested to get some stats. Could you send me the
report logged by Alt-SysReq-M after some [normal] swap utilization ?
Also, adding your cpu and hard drive type would help a lot (this way
I can have an idea about the ratio between the memory/cpu access
and the I/O throughput).

Since I'm asking for something, I believe it's fair to do the same.
Here is what I got after a working day using this patch.

CPU: AMD k6 3D 550Mhz (1097 bogomips)
HD:   IDE WDC ATA66

SysRq: Show Memory
Mem-info:
Free pages:        3116kB (     0kB HighMem)
( Free: 779, lru_cache: 14837 (239 478 717 956) )
  DMA: 119*4kB 22*8kB 1*16kB 1*32kB 3*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB = 892kB)
  Normal: 24*4kB 18*8kB 22*16kB 1*32kB 1*64kB 2*128kB 3*256kB 1*512kB 0*1024kB
0*2048kB = 2224kB)
  HighMem: = 0kB)
Swap cache: add 59950 [32651-27299], del 57064, find 134795/143195 [4413] 94%
kswapd: total 73264 overload 0 out of sync 0
kswapd: wakeup 649 [g 40857 y 11 o 2 r 0] free 22767 io 4579
kswapd: aged pages 5516 dirty pages 12
Free swap:       202316kB
30704 pages of RAM
0 pages of HIGHMEM
1089 reserved pages
19835 pages shared
2886 pages swap cached
0 pages in page table cache
Buffer memory:     2412kB


Thanks !

Ludo.

Andi Kleen wrote:

> On Wed, Jul 05, 2000 at 01:59:59AM +0200, ludovic fernandez wrote:
> > Hello guys,
> >
> > I'd like to submit a patch against linux-2.4.0-test2 regarding
> > the vm/kswapd. The patch is attached to this email. Sorry I don't
> > have access to a web or ftp server where I can put it.
>
> [...]
>
> Nice work. As a datapoint it runs fine on my UP machine with various loads
> and feels ``snappy''.
>
> -Andi
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
