Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0FBDF6B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 09:00:16 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so179137rvb.26
        for <linux-mm@kvack.org>; Fri, 10 Jul 2009 06:25:00 -0700 (PDT)
Date: Fri, 10 Jul 2009 21:24:55 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: OOM killer in 2.6.31-rc2
Message-ID: <20090710132455.GB17773@localhost>
References: <200907061056.00229.gene.heskett@verizon.net> <200907091042.38022.gene.heskett@verizon.net> <19030.22024.132029.196682@stoffel.org> <200907091703.06691.gene.heskett@verizon.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200907091703.06691.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Gene Heskett <gene.heskett@verizon.net>
Cc: John Stoffel <john@stoffel.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 05:03:06PM -0400, Gene Heskett wrote:
> On Thursday 09 July 2009, John Stoffel wrote:
> >>>>>> "Gene" == Gene Heskett <gene.heskett@verizon.net> writes:
> >
> >Gene> On Wednesday 08 July 2009, Wu Fengguang wrote:
> >>> On Wed, Jul 08, 2009 at 01:15:15PM +0800, Wu Fengguang wrote:
> >>>> On Tue, Jul 07, 2009 at 11:42:07PM -0400, Gene Heskett wrote:
> >
> >Gene> [...]
> >
> >>>> I guess your near 800MB slab cache is somehow under scanned.
> >>>
> >>> Gene, can you run .31 with this patch? When OOM happens, it will tell
> >>> us whether the majority slab pages are reclaimable. Another way to
> >>> find things out is to run `slabtop` when your system is moderately
> >>> loaded.
> >
> >Gene> Its been running continuously, and after 24 hours is now showing:
> >
> >Just wondering, is this your M2N-SLI Deluxe board?
> Yes.
> >I've got the same
> >board, with 4Gb of RAM and I haven't noticed any loss of RAM from my
> >looking (quickly) at top output.
> 
> I am short approximately 500 megs according to top:
> Mem:   3634228k total,  3522984k used,   111244k free,   308096k buffers
> Swap:  8385912k total,      568k used,  8385344k free,  2544716k cached
> 
> From dmesg:
> [    0.000000] TOM2: 0000000120000000 aka 4608M  <what is this?

That 4608M includes memory hole I guess.

> [...]
> [    0.000000] 2694MB HIGHMEM available.
> [    0.000000] 887MB LOWMEM available.
> 
> The bios signon does say 4092M IIRC.
> 
> >But I also haven't bothered to upgrade the BIOS on this board at all
> >since I got it back in March of 2008.  No need in my book so far.
> 
> I had been running the original bios, #1502, because 1604 and 1701 had very 
> poor uptimes.  1502 caused an oops about 15 lines into the boot but that 
> triggered a remap and it was bulletproof after that running a 32 bit 64G+PAE 
> kernel.  (I haven't quite made the jump to a 64 bit install, yet...)
> 
> >> uname -a
> >
> >Linux sail 2.6.31-rc1 #6 SMP PREEMPT Wed Jun 24 21:40:33 EDT 2009 x86_64
> > GNU/Linux
> 
> Linux coyote.coyote.den 2.6.31-rc2 #4 SMP PREEMPT Wed Jul 8 09:37:15 EDT 2009 
> i686 athlon i386 GNU/Linux
> >> cat /proc/meminfo
> >
> >MemTotal:        3987068 kB
> >MemFree:          170608 kB
> >Buffers:          355272 kB
> >Cached:          2034416 kB
> >SwapCached:            0 kB
> >Active:          1836284 kB
> >Inactive:        1482444 kB
> >Active(anon):     857076 kB
> >Inactive(anon):    86112 kB
> >Active(file):     979208 kB
> >Inactive(file):  1396332 kB
> >Unevictable:        3972 kB
> >Mlocked:            3972 kB
> >SwapTotal:             0 kB
> >SwapFree:              0 kB
> >Dirty:                36 kB
> >Writeback:             0 kB
> >AnonPages:        933160 kB
> >Mapped:           141188 kB
> >Slab:             398124 kB
> >SReclaimable:     348212 kB
> >SUnreclaim:        49912 kB
> >PageTables:        30916 kB
> >NFS_Unstable:          0 kB
> >Bounce:                0 kB
> >WritebackTmp:          0 kB
> >CommitLimit:     1993532 kB
> >Committed_AS:    1570980 kB
> >VmallocTotal:   34359738367 kB
> >VmallocUsed:      116160 kB
> >VmallocChunk:   34359584603 kB
> >DirectMap4k:        4992 kB
> >DirectMap2M:     4188160 kB
> 
> MemTotal:        3634228 kB
> MemFree:          114312 kB
> Buffers:          309088 kB
> Cached:          2541864 kB
> SwapCached:           72 kB
> Active:          1584988 kB
> Inactive:        1739508 kB
> Active(anon):     354584 kB
> Inactive(anon):   120072 kB
> Active(file):    1230404 kB
> Inactive(file):  1619436 kB
> Unevictable:         100 kB
> Mlocked:             100 kB
> HighTotal:       2759560 kB
> HighFree:          13020 kB
> LowTotal:         874668 kB
> LowFree:          101292 kB
> SwapTotal:       8385912 kB
> SwapFree:        8385344 kB
> Dirty:                52 kB
> Writeback:             0 kB
> AnonPages:        473576 kB
> Mapped:           111332 kB
> Slab:             143624 kB
> SReclaimable:     127820 kB
> SUnreclaim:        15804 kB
> PageTables:         8776 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    10203024 kB
> Committed_AS:    1029032 kB
> VmallocTotal:     122880 kB
> VmallocUsed:       44180 kB
> VmallocChunk:      65924 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       4096 kB
> DirectMap4k:        8184 kB
> DirectMap4M:      901120 kB
> 
> Huge diffs it appears. ??

Most relevant ones:

- 300+MB >4G memory is not reachable by kernel and user space
- 2.7GB high memory is not usable for slab caches and some other
  kernel users

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
