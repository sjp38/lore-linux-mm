Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E77846B0011
	for <linux-mm@kvack.org>; Fri,  4 May 2018 02:05:07 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n190-v6so1543985itg.4
        for <linux-mm@kvack.org>; Thu, 03 May 2018 23:05:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j193-v6sor89292itb.45.2018.05.03.23.05.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 23:05:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180502122314.GB30246@arm.com>
References: <1525247602-1565-1-git-send-email-opensource.ganesh@gmail.com> <20180502122314.GB30246@arm.com>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Fri, 4 May 2018 14:05:06 +0800
Message-ID: <CADAEsF86bXkK3qjJTKR6aqEEp_ch6HqSHeDy3afZF0wcVPFPRA@mail.gmail.com>
Subject: Re: [PATCH 1/2] arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

2018-05-02 20:23 GMT+08:00 Will Deacon <will.deacon@arm.com>:
> On Wed, May 02, 2018 at 03:53:21PM +0800, Ganesh Mahendran wrote:
>> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
>> enables Speculative Page Fault handler.
>
> Are there are tests for this? I'm really nervous about enabling it...

Hi, Will

I test the arm64 spf on Qcom SDM845 cpu with kernel 4.9.
It looks good for performance, and have not found stability issue yet.

Thanks.

>
> Will
>
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> ---
>> This patch is on top of Laurent's v10 spf
>> ---
>>  arch/arm64/Kconfig | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index eb2cf49..cd583a9 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -144,6 +144,7 @@ config ARM64
>>       select SPARSE_IRQ
>>       select SYSCTL_EXCEPTION_TRACE
>>       select THREAD_INFO_IN_TASK
>> +     select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT if SMP
>>       help
>>         ARM 64-bit (AArch64) Linux support.
>>
>> --
>> 1.9.1
>>
