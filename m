Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68E636B0253
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 08:50:22 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so461940330itb.3
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 05:50:22 -0800 (PST)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id 64si49738750iov.239.2017.01.04.05.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 05:50:21 -0800 (PST)
Received: by mail-it0-x231.google.com with SMTP id k132so13909272ita.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 05:50:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170104132831.GD18193@arm.com>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org> <20170104132831.GD18193@arm.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 4 Jan 2017 13:50:20 +0000
Message-ID: <CAKv+Gu8MdpVDCSjfum7AMtbgR6cTP5H+67svhDSu6bkaijvvyg@mail.gmail.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Hanjun Guo <hanjun.guo@linaro.org>, Yisheng Xie <xieyisheng1@huawei.com>, Robert Richter <rrichter@cavium.com>, James Morse <james.morse@arm.com>

On 4 January 2017 at 13:28, Will Deacon <will.deacon@arm.com> wrote:
> On Wed, Dec 14, 2016 at 09:11:47AM +0000, Ard Biesheuvel wrote:
>> The NUMA code may get confused by the presence of NOMAP regions within
>> zones, resulting in spurious BUG() checks where the node id deviates
>> from the containing zone's node id.
>>
>> Since the kernel has no business reasoning about node ids of pages it
>> does not own in the first place, enable CONFIG_HOLES_IN_ZONE to ensure
>> that such pages are disregarded.
>>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>>  arch/arm64/Kconfig | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 111742126897..0472afe64d55 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -614,6 +614,10 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
>>       def_bool y
>>       depends on NUMA
>>
>> +config HOLES_IN_ZONE
>> +     def_bool y
>> +     depends on NUMA
>> +
>>  source kernel/Kconfig.preempt
>>  source kernel/Kconfig.hz
>
> I'm happy to apply this, but I'll hold off until the first patch is queued
> somewhere, since this doesn't help without the VM_BUG_ON being moved.
>
> Alternatively, I can queue both if somebody from the mm camp acks the
> first patch.
>

Actually, I am not convinced the discussion is finalized. These
patches do fix the issue, but Robert also suggested an alternative fix
which may be preferable.

http://marc.info/?l=linux-arm-kernel&m=148190753510107&w=2

I haven't responded to it yet, due to the holidays, but I'd like to
explore that solution a bit further before applying anything, if you
don't mind.

Thanks,
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
