Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87C486B0261
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 13:41:35 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q128so85065426qkd.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:41:35 -0800 (PST)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com. [209.85.220.182])
        by mx.google.com with ESMTPS id b18si11206837qtc.75.2016.11.14.10.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 10:41:34 -0800 (PST)
Received: by mail-qk0-f182.google.com with SMTP id n21so106689472qka.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:41:34 -0800 (PST)
Subject: Re: [PATCHv2 5/6] arm64: Use __pa_symbol for _end
References: <20161102210054.16621-1-labbott@redhat.com>
 <20161102210054.16621-6-labbott@redhat.com>
 <20161102225241.GA19591@remoulade>
 <3724ea58-3c04-1248-8359-e2927da03aaf@redhat.com>
 <20161103155106.GF25852@remoulade>
 <20161114181937.GG3096@e104818-lin.cambridge.arm.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <06569a6b-3846-5e18-28c1-7c16a9697663@redhat.com>
Date: Mon, 14 Nov 2016 10:41:29 -0800
MIME-Version: 1.0
In-Reply-To: <20161114181937.GG3096@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On 11/14/2016 10:19 AM, Catalin Marinas wrote:
> On Thu, Nov 03, 2016 at 03:51:07PM +0000, Mark Rutland wrote:
>> On Wed, Nov 02, 2016 at 05:56:42PM -0600, Laura Abbott wrote:
>>> On 11/02/2016 04:52 PM, Mark Rutland wrote:
>>>> On Wed, Nov 02, 2016 at 03:00:53PM -0600, Laura Abbott wrote:
>>>>>
>>>>> __pa_symbol is technically the marco that should be used for kernel
>>>>> symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL.
>>>>
>>>> Nit: s/marco/macro/
>>>>
>>>> I see there are some other uses of __pa() that look like they could/should be
>>>> __pa_symbol(), e.g. in mark_rodata_ro().
>>>>
>>>> I guess strictly speaking those need to be updated to? Or is there a reason
>>>> that we should not?
>>>
>>> If the concept of __pa_symbol is okay then yes I think all uses of __pa
>>> should eventually be converted for consistency and debugging.
>>
>> I have no strong feelings either way about __pa_symbol(); I'm not clear on what
>> the purpose of __pa_symbol() is specifically, but I'm happy even if it's just
>> for consistency with other architectures.
> 
> At a quick grep, it seems to only be used by mips and x86 and a single
> place in mm/memblock.c.
> 
> Since we haven't seen any issues on arm/arm64 without this macro, can we
> not just continue to use __pa()?

Technically yes but if it's introduced it may be confusing why it's being
used some places but not others. Maybe the bounds in the debug virtual check
should just be adjusted so we don't need __pa_symbol along with a nice fat
comment explaining why. 

> 
> Thanks.
> 

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
