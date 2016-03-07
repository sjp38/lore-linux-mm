Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id F26166B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 08:11:13 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l68so85292857wml.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 05:11:13 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id m13si19055148wjw.8.2016.03.07.05.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 05:11:12 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id l68so69804551wml.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 05:11:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160307130338.GI19428@n2100.arm.linux.org.uk>
References: <nbjnq6$fim$1@ger.gmane.org> <56DD795C.9020903@suse.cz> <20160307130338.GI19428@n2100.arm.linux.org.uk>
From: "Matwey V. Kornilov" <matwey.kornilov@gmail.com>
Date: Mon, 7 Mar 2016 16:10:53 +0300
Message-ID: <CAJs94EY-oRyM_AgA=hy=k=jJEgZUxb4yU8jS_tjgk+N0ZWAbtw@mail.gmail.com>
Subject: Re: 4.5.0-rc6: kernel BUG at ../mm/memory.c:1879
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>

2016-03-07 16:03 GMT+03:00 Russell King - ARM Linux <linux@arm.linux.org.uk>:
> On Mon, Mar 07, 2016 at 01:51:40PM +0100, Vlastimil Babka wrote:
>> [+CC ARM, module maintainers/lists]
>>
>> On 03/07/2016 12:14 PM, Matwey V. Kornilov wrote:
>> >
>> >Hello,
>> >
>> >I see the following when try to boot 4.5.0-rc6 on ARM TI AM33xx based board.
>> >
>> >     [   13.907631] ------------[ cut here ]------------
>> >     [   13.912323] kernel BUG at ../mm/memory.c:1879!
>>
>> That's:
>> BUG_ON(addr >= end);
>>
>> where:
>> end = addr + size;
>>
>> All these variables are unsigned long, so they overflown?
>>
>> I don't know ARM much, and there's no code for decodecode, but if I get the
>> calling convention correctly, and the registers didn't change, both addr is
>> r1 and size is r2, i.e. both bf006000. Weird.
>
> A fix has been recently merged for this.  Look out for
> "ARM: 8544/1: set_memory_xx fixes"
>

Many thanks, I'll try again with -rc7.

> --
> RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.



-- 
With best regards,
Matwey V. Kornilov
http://blog.matwey.name
xmpp://0x2207@jabber.ru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
