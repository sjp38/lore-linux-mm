Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E16586B0062
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:38:47 -0400 (EDT)
Received: by mail-fx0-f178.google.com with SMTP id 26so363730fxm.38
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312103847.GA20210@localhost>
References: <20090311114353.GA759@localhost> <20090311121123.GA7656@localhost>
	 <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com>
	 <20090311122611.GA8804@localhost>
	 <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
	 <20090312075952.GA19331@localhost>
	 <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com>
	 <20090312081113.GA19506@localhost>
	 <e2dc2c680903120117j7be962b2xd63f3296f8f65a46@mail.gmail.com>
	 <20090312103847.GA20210@localhost>
Date: Thu, 12 Mar 2009 12:38:46 +0100
Message-ID: <e2dc2c680903120438i27e209c2h28c61704299b8b4f@mail.gmail.com>
Subject: Re: Memory usage per memory zone
From: jack marrow <jackmarrow2@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Can you paste the /proc/meminfo after doing 'echo 3 > drop_caches'?

http://pastebin.com/mce24730

>> I thought the kernel dropped caches if a program needs the ram?
>
> Sure, but something is unreclaimable... Maybe some process is taking a
> lot of shared memory(shm)? What's the output of `lsof`?

I can't paste that, but I expect oracle is using it.

>
>> >
>> > MemTotal: =A0 =A0 =A01034496 kB
>> > MemFree: =A0 =A0 =A0 =A0 95600 kB
>> > Buffers: =A0 =A0 =A0 =A0 49916 kB
>> > Cached: =A0 =A0 =A0 =A0 761544 kB
>> > SwapCached: =A0 =A0 =A0 =A0 =A00 kB
>> > Active: =A0 =A0 =A0 =A0 =A080484 kB
>> > Inactive: =A0 =A0 =A0 749960 kB
>> > HighTotal: =A0 =A0 =A0131008 kB
>> > HighFree: =A0 =A0 =A0 =A068480 kB
>> > LowTotal: =A0 =A0 =A0 903488 kB
>> > LowFree: =A0 =A0 =A0 =A0 27120 kB
>> > SwapTotal: =A0 =A0 2040212 kB
>> > SwapFree: =A0 =A0 =A02039780 kB
>> > Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A0 4 kB
>> > Writeback: =A0 =A0 =A0 =A0 =A0 0 kB
>> > Mapped: =A0 =A0 =A0 =A0 =A032636 kB
>> > Slab: =A0 =A0 =A0 =A0 =A0 =A093856 kB
>> > CommitLimit: =A0 2557460 kB
>> > Committed_AS: =A0 129980 kB
>> > PageTables: =A0 =A0 =A0 1800 kB
>> > VmallocTotal: =A0 106488 kB
>> > VmallocUsed: =A0 =A0 =A03372 kB
>> > VmallocChunk: =A0 102616 kB
>> > HugePages_Total: =A0 =A0 0
>> > HugePages_Free: =A0 =A0 =A00
>> > Hugepagesize: =A0 =A0 2048 kB
>> >
>> > Is upgrading the kernel an option for you?
>>
>> No :(
>>
>> I think shoving some more ram in the box is the best doable option.
>> Would this help here?
>
> There have been huge amounts of change sets in mm area since 2.6.9...
>
>> To do that I need to say "look at how much cache we are using for
>> files, that cache is in the high mem zone (look here) so let's put
>> some more ram in". Does the cache always live in the high mem zone?
>
> Both highmem and normal zones will be used for caches.
>
> Thanks,
> Fengguang
>
>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
