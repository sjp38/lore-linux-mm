Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 644006B0083
	for <linux-mm@kvack.org>; Tue, 12 May 2009 09:30:10 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1785291ywm.26
        for <linux-mm@kvack.org>; Tue, 12 May 2009 06:30:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090511103651.49d852f8@pedra.chehab.org>
References: <20090508085310.31326.38083.sendpatchset@rx1.opensource.se>
	 <20090508130658.813e29c1.akpm@linux-foundation.org>
	 <20090511103651.49d852f8@pedra.chehab.org>
Date: Tue, 12 May 2009 22:30:37 +0900
Message-ID: <aec7e5c30905120630k7cbc245dh211dbd0472928a2d@mail.gmail.com>
Subject: Re: [PATCH] videobuf-dma-contig: zero copy USERPTR support V3
From: Magnus Damm <magnus.damm@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mauro Carvalho Chehab <mchehab@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, hverkuil@xs4all.nl, linux-mm@kvack.org, lethal@linux-sh.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Mon, May 11, 2009 at 10:36 PM, Mauro Carvalho Chehab
<mchehab@infradead.org> wrote:
> Em Fri, 8 May 2009 13:06:58 -0700
> Andrew Morton <akpm@linux-foundation.org> escreveu:
>
>> On Fri, 08 May 2009 17:53:10 +0900
>> Magnus Damm <magnus.damm@gmail.com> wrote:
>>
>> > From: Magnus Damm <damm@igel.co.jp>
>> >
>> > This is V3 of the V4L2 videobuf-dma-contig USERPTR zero copy patch.
>> >
>> > Since videobuf-dma-contig is designed to handle physically contiguous
>> > memory, this patch modifies the videobuf-dma-contig code to only accept
>> > a user space pointer to physically contiguous memory. For now only
>> > VM_PFNMAP vmas are supported, so forget hotplug.
>> >
>> > On SuperH Mobile we use this with our sh_mobile_ceu_camera driver
>> > together with various multimedia accelerator blocks that are exported to
>> > user space using UIO. The UIO kernel code exports physically contiguous
>> > memory to user space and lets the user space application mmap() this memory
>> > and pass a pointer using the USERPTR interface for V4L2 zero copy operation.
>> >
>> > With this approach we support zero copy capture, hardware scaling and
>> > various forms of hardware encoding and decoding.
>> >
>> > Signed-off-by: Magnus Damm <damm@igel.co.jp>
>
> Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>

Thank you!

>> What does it do, how does it do it and why does it do it?
>
> A good documentation is a really good idea here. There videobuf internals are
> very complex. A good documentation for it is very important to keep it updated.

I've just posted a little patch that adds function descriptions,
hopefully that is one step in the right direction.

> I would also suggest if you could also take a look at videobuf-vmalloc and implement a
> similar method to provide USERPTR. The vmalloc flavor can easily be tested with
> the virtual (vivi) video driver, so it helps people to better understand how
> videobuf works. It will also help the USB drivers that use videobuf to use USERPTR.

Yeah, supporting USERPTR with vivi sounds like a good plan. I'm not
sure how much work it involves though. The comment in the
videobuf-vmalloc header says that the buffer code assumes that the
driver does not touch the data, but I think that's exactly how vivi
generates the frame data for us. =)

I need to figure out the best way to grab references to user space
pages and map them virtually contiguous like vmalloc does. This will
take a bit of time, so don't expect anything submitted in time for
v2.6.31. I've put it fairly high on my TODO list.

Thanks for your help!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
