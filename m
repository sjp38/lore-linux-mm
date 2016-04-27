Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B98EA6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:50:36 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so79883856pac.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 09:50:36 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id uv6si6145813pac.176.2016.04.27.09.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 09:50:35 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id bt5so21282045pac.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 09:50:35 -0700 (PDT)
Subject: Re: [BUG] set_pte_at: racy dirty state clearing warning
References: <57180A53.3000207@linaro.org>
 <20160421084946.GA23774@e104818-lin.cambridge.arm.com>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <50501020-db93-cb6c-c2d9-b59efc05c30d@linaro.org>
Date: Wed, 27 Apr 2016 09:50:33 -0700
MIME-Version: 1.0
In-Reply-To: <20160421084946.GA23774@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 4/21/2016 1:49 AM, Catalin Marinas wrote:
> On Wed, Apr 20, 2016 at 04:01:39PM -0700, Shi, Yang wrote:
>> When I enable memory comact via
>>
>> # echo 1 > /proc/sys/vm/compact_memory
>>
>> I got the below WARNING:
>>
>> set_pte_at: racy dirty state clearing: 0x0068000099371bd3 ->
>> 0x0068000099371fd3
>> ------------[ cut here ]------------
>> WARNING: CPU: 5 PID: 294 at ./arch/arm64/include/asm/pgtable.h:227
>> ptep_set_access_flags+0x138/0x1b8
>> Modules linked in:
>
> Do you have this patch applied:
>
> http://article.gmane.org/gmane.linux.ports.arm.kernel/492239
>
> It's also queued into -next as commit 66dbd6e61a52.

No, but I just applied it, it works.

Thanks,
Yang

>
>> My kernel has ARM64_HW_AFDBM enabled, but LS2085 is not ARMv8.1.
>>
>> The code shows it just check if ARM64_HW_AFDBM is enabled or not, but
>> doesn't check if the CPU really has such capability.
>>
>> So, it might be better to have the capability checked runtime?
>
> The warnings are there to spot any incorrect uses of the pte accessors
> even before you run on AF/DBM-capable hardware.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
