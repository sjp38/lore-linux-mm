Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 238606B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 08:51:06 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so35310580wic.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 05:51:05 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id dx2si10778969wib.2.2015.08.22.05.51.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 05:51:04 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so35147781wic.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 05:51:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150822100922.GA25039@gmail.com>
References: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
	<20150813065040.GA17983@gmail.com>
	<20150813081641.GA14402@gmail.com>
	<20150813090119.GA10280@arm.com>
	<CAPAsAGxk2+v5VG77cOHAThsXyWx-_UJ1XVeJProaa0gQWH5jvA@mail.gmail.com>
	<20150813112428.GG10280@arm.com>
	<20150813172310.GK10280@arm.com>
	<20150822100922.GA25039@gmail.com>
Date: Sat, 22 Aug 2015 15:51:03 +0300
Message-ID: <CAPAsAGz7Ew3oomDnYvHbq-ANhp5bhZGeUtc-iHXJX4PW5ZUcyg@mail.gmail.com>
Subject: Re: [PATCH 0/2] x86/KASAN updates for 4.3
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

2015-08-22 13:09 GMT+03:00 Ingo Molnar <mingo@kernel.org>:
>
> * Will Deacon <will.deacon@arm.com> wrote:
>
>> On Thu, Aug 13, 2015 at 12:24:28PM +0100, Will Deacon wrote:
>> > On Thu, Aug 13, 2015 at 12:02:26PM +0100, Andrey Ryabinin wrote:
>> > > 2015-08-13 12:01 GMT+03:00 Will Deacon <will.deacon@arm.com>:
>> > > > Yes please, works for me! If we're targetting 4.3, then please can you base
>> > > > on 4.2-rc4, as that's what our current arm64 queue is using?
>> > > >
>> > >
>> > > Does this mean that we are targeting arm64 part for 4.3 too?
>> >
>> > It depends on how well it merges with our current queue and whether it
>> > holds up to regression testing. The patches have been reviewed, so I'm
>> > comfortable with the content, but we're not at a stage where we can debug
>> > and fix any failures that might crop up from the merge.
>>
>> Scratch that :(
>>
>> I tried this out under EFI and it dies horribly in the stub code because
>> we're missing at least one KASAN_SANITIZE_ Makefile entry.
>>
>> So I think this needs longer to stew before hitting mainline. By all means
>> get the x86 dependencies in for 4.3, but the arm64 port can probably use
>> another cycle to iron out the bugs.
>
> Is there any known problem with the two patches in this series, or can I apply
> them?
>

None, as far as I know.

BTW, the second patch was  Acked-by: Catalin Marinas <catalin.marinas@arm.com>
(https://lkml.org/lkml/2015/8/11/546). I just forgot to add this into changelog.



> Thanks,
>
>         Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
