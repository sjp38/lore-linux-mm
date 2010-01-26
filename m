Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D5216B00A9
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:50:22 -0500 (EST)
Received: by ewy24 with SMTP id 24so343285ewy.6
        for <linux-mm@kvack.org>; Tue, 26 Jan 2010 13:50:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B5F5794.8020302@cs.helsinki.fi>
References: <74fd948d1001261121r7e6d03a4i75ce40705abed4e0@mail.gmail.com>
	 <4B5F52FE.5000201@crca.org.au> <1264539045.3536.1348.camel@calx>
	 <4B5F5794.8020302@cs.helsinki.fi>
Date: Tue, 26 Jan 2010 21:50:19 +0000
Message-ID: <74fd948d1001261350n2f26c057ubbe056d11d19abf2@mail.gmail.com>
Subject: Re: BUG at mm/slab.c:2990 with 2.6.33-rc5-tuxonice
From: Pedro Ribeiro <pedrib@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nigel Cunningham <ncunningham@crca.org.au>
List-ID: <linux-mm.kvack.org>

2010/1/26 Pekka Enberg <penberg@cs.helsinki.fi>:
> Matt Mackall wrote:
>>
>> On Wed, 2010-01-27 at 07:39 +1100, Nigel Cunningham wrote:
>>>
>>> Hi.
>>>
>>> Pedro Ribeiro wrote:
>>>>
>>>> Hi,
>>>>
>>>> I hit a bug at mm/slab.c:2990 with .33-rc5.
>>>> Unfortunately nothing more is available than a screen picture with a
>>>> crash dump, although it is a good one.
>>>> The bug was hit almost at the end of a hibernation cycle with
>>>> Tux-on-Ice, while saving memory contents to an encrypted swap
>>>> partition.
>>>>
>>>> The image is here http://img264.imageshack.us/img264/9634/mmslab.jpg
>>>> (150 kb)
>>>>
>>>> Hopefully it is of any use for you. Please let me know if you need any
>>>> more info.
>>>
>>> Looks to me to be completely unrelated to TuxOnIce - at least at a first
>>> glance.
>>>
>>> Ccing the slab allocator maintainers listed in MAINTAINERS.
>>
>> Not sure if this will do us any good, it's the second oops.
>
> Looks like slab corruption to me which is usually not a slab bug but caused
> by buggy callers. Is CONFIG_DEBUG_SLAB enabled?
>

I have enabled it and compiled the kernel. As soon as I hit the bug, I
will send a photo here.

Regards,
Pedro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
