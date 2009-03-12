Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5D4266B0082
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:52:32 -0400 (EDT)
Date: Thu, 12 Mar 2009 19:51:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Memory usage per memory zone
Message-ID: <20090312115147.GA20785@localhost>
References: <20090311121123.GA7656@localhost> <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com> <20090311122611.GA8804@localhost> <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com> <20090312075952.GA19331@localhost> <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com> <20090312081113.GA19506@localhost> <e2dc2c680903120117j7be962b2xd63f3296f8f65a46@mail.gmail.com> <20090312103847.GA20210@localhost> <e2dc2c680903120438i27e209c2h28c61704299b8b4f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2dc2c680903120438i27e209c2h28c61704299b8b4f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: jack marrow <jackmarrow2@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 01:38:46PM +0200, jack marrow wrote:
> > Can you paste the /proc/meminfo after doing 'echo 3 > drop_caches'?
> 
> http://pastebin.com/mce24730
> 
> >> I thought the kernel dropped caches if a program needs the ram?
> >
> > Sure, but something is unreclaimable... Maybe some process is taking a
> > lot of shared memory(shm)? What's the output of `lsof`?
> 
> I can't paste that, but I expect oracle is using it.

Oh well...

But from the meminfo, there are 1.2G mapped pages. That could be a big
trouble for reclaiming.  Recent kernels can better handle this situation.

Thanks,
Fengguang
---

# cat /proc/meminfo
MemTotal:      3895404 kB
MemFree:       2472656 kB
Buffers:           412 kB
Cached:         239716 kB
SwapCached:     202652 kB
Active:        1275212 kB
Inactive:        34584 kB
HighTotal:     3014592 kB
HighFree:      1684032 kB
LowTotal:       880812 kB
LowFree:        788624 kB
SwapTotal:     2040212 kB
SwapFree:      1626756 kB
Dirty:             104 kB
Writeback:           0 kB
Mapped:        1247000 kB
Slab:            80040 kB
CommitLimit:   3987912 kB
Committed_AS:  8189040 kB
PageTables:      18792 kB
VmallocTotal:   106488 kB
VmallocUsed:      3072 kB
VmallocChunk:   102980 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     2048 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
