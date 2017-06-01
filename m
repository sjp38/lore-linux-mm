Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79B506B0350
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:58:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 62so49385678pft.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:58:17 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40125.outbound.protection.outlook.com. [40.107.4.125])
        by mx.google.com with ESMTPS id c22si35424823plk.79.2017.06.01.09.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 09:58:16 -0700 (PDT)
Subject: Re: [PATCH 3/4] arm64/kasan: don't allocate extra shadow memory
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
 <20170601162338.23540-3-aryabinin@virtuozzo.com>
 <20170601163442.GC17711@leverpostej>
 <CACT4Y+aCKDF95mK2-nuiV0+XineHha3y+6PCW0-EorOaY=TFng@mail.gmail.com>
 <20170601165205.GA8191@leverpostej>
 <75ea368f-9268-44fd-f3f6-2a48dc8d2fe8@virtuozzo.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <31a41822-35e1-1b4a-09f7-0a99571ee89a@virtuozzo.com>
Date: Thu, 1 Jun 2017 20:00:09 +0300
MIME-Version: 1.0
In-Reply-To: <75ea368f-9268-44fd-f3f6-2a48dc8d2fe8@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org



On 06/01/2017 07:59 PM, Andrey Ryabinin wrote:
> 
> 
> On 06/01/2017 07:52 PM, Mark Rutland wrote:
>> On Thu, Jun 01, 2017 at 06:45:32PM +0200, Dmitry Vyukov wrote:
>>> On Thu, Jun 1, 2017 at 6:34 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>>>> On Thu, Jun 01, 2017 at 07:23:37PM +0300, Andrey Ryabinin wrote:
>>>>> We used to read several bytes of the shadow memory in advance.
>>>>> Therefore additional shadow memory mapped to prevent crash if
>>>>> speculative load would happen near the end of the mapped shadow memory.
>>>>>
>>>>> Now we don't have such speculative loads, so we no longer need to map
>>>>> additional shadow memory.
>>>>
>>>> I see that patch 1 fixed up the Linux helpers for outline
>>>> instrumentation.
>>>>
>>>> Just to check, is it also true that the inline instrumentation never
>>>> performs unaligned accesses to the shadow memory?
>>>
> 
> Correct, inline instrumentation assumes that all accesses are properly aligned as it
> required by C standard. I knew that the kernel violates this rule in many places,
> therefore I decided to add checks for unaligned accesses in outline case.
> 
> 
>>> Inline instrumentation generally accesses only a single byte.
>>
>> Sorry to be a little pedantic, but does that mean we'll never access the
>> additional shadow, or does that mean it's very unlikely that we will?
>>
>> I'm guessing/hoping it's the former!
>>
> 
> Outline will never access additional shadow byte: https://github.com/google/sanitizers/wiki/AddressSanitizerAlgorithm#unaligned-accesses

s/Outline/inline  of course.

> 
>> Thanks,
>> Mark.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
