Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 950DA6B004D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:15:45 -0400 (EDT)
Date: Thu, 12 Mar 2009 19:14:43 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Memory usage per memory zone
Message-ID: <20090312111443.GA20569@localhost>
References: <20090311114353.GA759@localhost> <e2dc2c680903110451m3cfa35d9s7a9fd942bcee39eb@mail.gmail.com> <20090311121123.GA7656@localhost> <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com> <20090311122611.GA8804@localhost> <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com> <20090312075952.GA19331@localhost> <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com> <20090312081113.GA19506@localhost> <e2dc2c680903120148j1aee0759td49055be059e33ae@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e2dc2c680903120148j1aee0759td49055be059e33ae@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: jack marrow <jackmarrow2@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 10:48:42AM +0200, jack marrow wrote:
> (Didn't reply all:)
>
> 2009/3/12 Wu Fengguang <fengguang.wu@intel.com>:
> > On Thu, Mar 12, 2009 at 10:04:17AM +0200, jack marrow wrote:
> >> 2009/3/12 Wu Fengguang <fengguang.wu@intel.com>:
> >> > On Thu, Mar 12, 2009 at 09:53:27AM +0200, jack marrow wrote:
> >> >> > Can you paste /proc/vmstat, /proc/meminfo, /proc/zoneinfo and
> >> >> > /proc/slabinfo? Thank you.
> >> >>
> >> >> Sure, but I don't know if it will help.
> >> >>
> >> >> The oom info was from in the night, the rest is from now. I have no zoneinfo.
> >> >>
> >> >> http://pastebin.com/m67409bc0
> >> >
> >> > Thank you! So you are running a pretty old kernel?
> >> >
> >>
> >> Yes. Kernel.2.6.9-78.
> >>
> >> Added more output from the other oom kills here:
> >> A http://pastebin.com/m76fc473d
> >>
> >> If I could just find a way to find out what is using up all the memory
> >> in a zone I could go away happy :)
> >
> > But the highmem zone wont help you much, since you have a large 900M
> > normal zone and a tiny 100M highmem zone ;)

btw, how much physical memory do you have?
It's weird that meminfo says 1G but Mem-Info says 4G...

> MemTotal: A  A  A 1034496 kB
> MemFree: A  A  A  A  95600 kB
> Buffers: A  A  A  A  49916 kB
> Cached: A  A  A  A  761544 kB
> SwapCached: A  A  A  A  A 0 kB
> Active: A  A  A  A  A 80484 kB
> Inactive: A  A  A  749960 kB
> HighTotal: A  A  A 131008 kB
> HighFree: A  A  A  A 68480 kB
> LowTotal: A  A  A  903488 kB
> LowFree: A  A  A  A  27120 kB
> SwapTotal: A  A  2040212 kB
> SwapFree: A  A  A 2039780 kB

Free pages:       16808kB (1664kB HighMem)
Active:457312 inactive:273805 dirty:0 writeback:0 unstable:0 free:4202 slab:5897 mapped:390707 pagetables:5068
DMA free:12408kB min:64kB low:128kB high:192kB active:0kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? yes
protections[]: 0 0 0
Normal free:2736kB min:3728kB low:7456kB high:11184kB active:256kB inactive:16kB present:901120kB pages_scanned:2782 all_unre
claimable? yes
protections[]: 0 0 0
HighMem free:1664kB min:512kB low:1024kB high:1536kB active:1828992kB inactive:1095204kB present:3014656kB pages_scanned:0 al
l_unreclaimable? no
protections[]: 0 0 0
DMA: 4*4kB 5*8kB 2*16kB 1*32kB 4*64kB 2*128kB 2*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12408kB
Normal: 0*4kB 0*8kB 1*16kB 1*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2736kB
HighMem: 320*4kB 0*8kB 0*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1664kB
448110 pagecache pages
Swap cache: add 787243, delete 731019, find 235217/281007, race 0+3
0 bounce buffer pages
Free swap:       1558736kB
983040 pages of RAM
753648 pages of HIGHMEM
9253 reserved pages
253474 pages shared
56224 pages swap cached
Out of Memory: Killed process 28258 (oracle).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
