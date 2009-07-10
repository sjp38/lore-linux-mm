Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 808E76B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:53:25 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so178422rvb.26
        for <linux-mm@kvack.org>; Fri, 10 Jul 2009 06:18:08 -0700 (PDT)
Date: Fri, 10 Jul 2009 21:18:01 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: OOM killer in 2.6.31-rc2
Message-ID: <20090710131801.GA17773@localhost>
References: <200907061056.00229.gene.heskett@verizon.net> <200907091042.38022.gene.heskett@verizon.net> <19030.22024.132029.196682@stoffel.org> <200907091703.06691.gene.heskett@verizon.net> <19031.15772.404288.544946@stoffel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19031.15772.404288.544946@stoffel.org>
Sender: owner-linux-mm@kvack.org
To: John Stoffel <john@stoffel.org>
Cc: Gene Heskett <gene.heskett@verizon.net>, Linux Kernel list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 09:09:48AM -0400, John Stoffel wrote:
> >>>>> "Gene" == Gene Heskett <gene.heskett@verizon.net> writes:
> 
> Gene> On Thursday 09 July 2009, John Stoffel wrote:
> >>>>>>> "Gene" == Gene Heskett <gene.heskett@verizon.net> writes:
> >> 
> Gene> On Wednesday 08 July 2009, Wu Fengguang wrote:
> >>>> On Wed, Jul 08, 2009 at 01:15:15PM +0800, Wu Fengguang wrote:
> >>>>> On Tue, Jul 07, 2009 at 11:42:07PM -0400, Gene Heskett wrote:
> >> 
> Gene> [...]
> >> 
> >>>>> I guess your near 800MB slab cache is somehow under scanned.
> >>>> 
> >>>> Gene, can you run .31 with this patch? When OOM happens, it will tell
> >>>> us whether the majority slab pages are reclaimable. Another way to
> >>>> find things out is to run `slabtop` when your system is moderately
> >>>> loaded.
> >> 
> Gene> Its been running continuously, and after 24 hours is now showing:
> >> 
> >> Just wondering, is this your M2N-SLI Deluxe board?
> Gene> Yes.
> >> I've got the same
> >> board, with 4Gb of RAM and I haven't noticed any loss of RAM from my
> >> looking (quickly) at top output.
> 
> Gene> I am short approximately 500 megs according to top:
> Gene> Mem:   3634228k total,  3522984k used,   111244k free,   308096k buffers
> Gene> Swap:  8385912k total,      568k used,  8385344k free,  2544716k cached
> 
> Gene> From dmesg:
> Gene> [    0.000000] TOM2: 0000000120000000 aka 4608M  <what is this?
> Gene> [...]
> Gene> [    0.000000] 2694MB HIGHMEM available.
> Gene> [    0.000000] 887MB LOWMEM available.
> 
> Gene> The bios signon does say 4092M IIRC.
> 
> >> But I also haven't bothered to upgrade the BIOS on this board at all
> >> since I got it back in March of 2008.  No need in my book so far.
> 
> Gene> I had been running the original bios, #1502, because 1604 and
> Gene> 1701 had very poor uptimes.  1502 caused an oops about 15 lines
> Gene> into the boot but that triggered a remap and it was bulletproof
> Gene> after that running a 32 bit 64G+PAE kernel.  (I haven't quite
> Gene> made the jump to a 64 bit install, yet...)
> 
> Why haven't you made the laep to 64bit yet?  To me, that seems to be
> the real solution here, not hacks like the HIGHMEM4G and HIGHMEM64G,
> esp when your hardware is 64Bit by default.  

Sure 64bit kernel would be the best option for Gene :)

> I've made the leap and I've never looked back.  Haven't missed any
> 32bit only apps, and if I really needed them, I'd just load the 32bit
> libraries if need be.

But for now I'd appreciate a lot if Gene can run a HIGHMEM64G kernel
with the provided patch, so as to collect one full OOM message for us
to analyze :) The previous OOM message missed the most important data
from zone Normal..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
