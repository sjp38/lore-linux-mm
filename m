Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C693F6B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 08:01:52 -0400 (EDT)
Received: by fxm26 with SMTP id 26so372306fxm.38
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 05:01:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312115147.GA20785@localhost>
References: <20090311121123.GA7656@localhost> <20090311122611.GA8804@localhost>
	 <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
	 <20090312075952.GA19331@localhost>
	 <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com>
	 <20090312081113.GA19506@localhost>
	 <e2dc2c680903120117j7be962b2xd63f3296f8f65a46@mail.gmail.com>
	 <20090312103847.GA20210@localhost>
	 <e2dc2c680903120438i27e209c2h28c61704299b8b4f@mail.gmail.com>
	 <20090312115147.GA20785@localhost>
Date: Thu, 12 Mar 2009 13:01:49 +0100
Message-ID: <e2dc2c680903120501m3b6057b8v754b3518c4fa80d@mail.gmail.com>
Subject: Re: Memory usage per memory zone
From: jack marrow <jackmarrow2@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

2009/3/12 Wu Fengguang <fengguang.wu@intel.com>:
> On Thu, Mar 12, 2009 at 01:38:46PM +0200, jack marrow wrote:
>> > Can you paste the /proc/meminfo after doing 'echo 3 > drop_caches'?
>>
>> http://pastebin.com/mce24730
>>
>> >> I thought the kernel dropped caches if a program needs the ram?
>> >
>> > Sure, but something is unreclaimable... Maybe some process is taking a
>> > lot of shared memory(shm)? What's the output of `lsof`?
>>
>> I can't paste that, but I expect oracle is using it.
>
> Oh well...
>
> But from the meminfo, there are 1.2G mapped pages. That could be a big
> trouble for reclaiming. =A0Recent kernels can better handle this situatio=
n.
>
> Thanks,
> Fengguang
> ---
>
> # cat /proc/meminfo
> MemTotal: =A0 =A0 =A03895404 kB
> MemFree: =A0 =A0 =A0 2472656 kB
> Buffers: =A0 =A0 =A0 =A0 =A0 412 kB
> Cached: =A0 =A0 =A0 =A0 239716 kB
> SwapCached: =A0 =A0 202652 kB
> Active: =A0 =A0 =A0 =A01275212 kB
> Inactive: =A0 =A0 =A0 =A034584 kB
> HighTotal: =A0 =A0 3014592 kB
> HighFree: =A0 =A0 =A01684032 kB
> LowTotal: =A0 =A0 =A0 880812 kB
> LowFree: =A0 =A0 =A0 =A0788624 kB
> SwapTotal: =A0 =A0 2040212 kB
> SwapFree: =A0 =A0 =A01626756 kB
> Dirty: =A0 =A0 =A0 =A0 =A0 =A0 104 kB
> Writeback: =A0 =A0 =A0 =A0 =A0 0 kB
> Mapped: =A0 =A0 =A0 =A01247000 kB
> Slab: =A0 =A0 =A0 =A0 =A0 =A080040 kB
> CommitLimit: =A0 3987912 kB
> Committed_AS: =A08189040 kB
> PageTables: =A0 =A0 =A018792 kB
> VmallocTotal: =A0 106488 kB
> VmallocUsed: =A0 =A0 =A03072 kB
> VmallocChunk: =A0 102980 kB
> HugePages_Total: =A0 =A0 0
> HugePages_Free: =A0 =A0 =A00
> Hugepagesize: =A0 =A0 2048 kB
>

Thanks for all your help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
