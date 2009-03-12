Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9AC6F6B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:48:44 -0400 (EDT)
Received: by bwz18 with SMTP id 18so310246bwz.38
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 01:48:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312081113.GA19506@localhost>
References: <e2dc2c680903110341g6c9644b8j87ce3b364807e37f@mail.gmail.com>
	 <20090311114353.GA759@localhost>
	 <e2dc2c680903110451m3cfa35d9s7a9fd942bcee39eb@mail.gmail.com>
	 <20090311121123.GA7656@localhost>
	 <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com>
	 <20090311122611.GA8804@localhost>
	 <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
	 <20090312075952.GA19331@localhost>
	 <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com>
	 <20090312081113.GA19506@localhost>
Date: Thu, 12 Mar 2009 09:48:42 +0100
Message-ID: <e2dc2c680903120148j1aee0759td49055be059e33ae@mail.gmail.com>
Subject: Re: Memory usage per memory zone
From: jack marrow <jackmarrow2@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(Didn't reply all:)

2009/3/12 Wu Fengguang <fengguang.wu@intel.com>:
> On Thu, Mar 12, 2009 at 10:04:17AM +0200, jack marrow wrote:
>> 2009/3/12 Wu Fengguang <fengguang.wu@intel.com>:
>> > On Thu, Mar 12, 2009 at 09:53:27AM +0200, jack marrow wrote:
>> >> > Can you paste /proc/vmstat, /proc/meminfo, /proc/zoneinfo and
>> >> > /proc/slabinfo? Thank you.
>> >>
>> >> Sure, but I don't know if it will help.
>> >>
>> >> The oom info was from in the night, the rest is from now. I have no z=
oneinfo.
>> >>
>> >> http://pastebin.com/m67409bc0
>> >
>> > Thank you! So you are running a pretty old kernel?
>> >
>>
>> Yes. Kernel.2.6.9-78.
>>
>> Added more output from the other oom kills here:
>> =A0http://pastebin.com/m76fc473d
>>
>> If I could just find a way to find out what is using up all the memory
>> in a zone I could go away happy :)
>
> But the highmem zone wont help you much, since you have a large 900M
> normal zone and a tiny 100M highmem zone ;)
>
> The cached files seem to be the memory killer:

I ran an echo 3 > drop_caches yesterday, I was hoping to come in and
find no oom kill. Oh well :)

I thought the kernel dropped caches if a program needs the ram?

>
> MemTotal: =A0 =A0 =A01034496 kB
> MemFree: =A0 =A0 =A0 =A0 95600 kB
> Buffers: =A0 =A0 =A0 =A0 49916 kB
> Cached: =A0 =A0 =A0 =A0 761544 kB
> SwapCached: =A0 =A0 =A0 =A0 =A00 kB
> Active: =A0 =A0 =A0 =A0 =A080484 kB
> Inactive: =A0 =A0 =A0 749960 kB
> HighTotal: =A0 =A0 =A0131008 kB
> HighFree: =A0 =A0 =A0 =A068480 kB
> LowTotal: =A0 =A0 =A0 903488 kB
> LowFree: =A0 =A0 =A0 =A0 27120 kB
> SwapTotal: =A0 =A0 2040212 kB
> SwapFree: =A0 =A0 =A02039780 kB
> Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A0 4 kB
> Writeback: =A0 =A0 =A0 =A0 =A0 0 kB
> Mapped: =A0 =A0 =A0 =A0 =A032636 kB
> Slab: =A0 =A0 =A0 =A0 =A0 =A093856 kB
> CommitLimit: =A0 2557460 kB
> Committed_AS: =A0 129980 kB
> PageTables: =A0 =A0 =A0 1800 kB
> VmallocTotal: =A0 106488 kB
> VmallocUsed: =A0 =A0 =A03372 kB
> VmallocChunk: =A0 102616 kB
> HugePages_Total: =A0 =A0 0
> HugePages_Free: =A0 =A0 =A00
> Hugepagesize: =A0 =A0 2048 kB
>
> Is upgrading the kernel an option for you?

No :(

I think shoving some more ram in the box is the best doable option.
Would this help here?

To do that I need to say "look at how much cache we are using for
files, that cache is in the high mem zone (look here) so let's put
some more ram in". Does the cache always live in the high mem zone?

>
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
