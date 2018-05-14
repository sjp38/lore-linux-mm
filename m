Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13F106B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:05:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id k13-v6so12256486oiw.3
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:05:05 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q185-v6si2993541oib.405.2018.05.14.08.05.03
        for <linux-mm@kvack.org>;
        Mon, 14 May 2018 08:05:03 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v10 02/25] x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
	<1523975611-15978-3-git-send-email-ldufour@linux.vnet.ibm.com>
	<87sh72jtmn.fsf@e105922-lin.cambridge.arm.com>
	<c289a58f-8afa-34c7-2624-c7bd2f6fcf48@linux.vnet.ibm.com>
Date: Mon, 14 May 2018 16:05:01 +0100
In-Reply-To: <c289a58f-8afa-34c7-2624-c7bd2f6fcf48@linux.vnet.ibm.com>
	(Laurent Dufour's message of "Mon, 14 May 2018 16:47:39 +0200")
Message-ID: <87o9hi46si.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists., ozlabs.org, x86@kernel.org

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> On 08/05/2018 13:04, Punit Agrawal wrote:
>> Hi Laurent,
>> 
>> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
>> 
>>> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT which turns on the
>>> Speculative Page Fault handler when building for 64bit.
>>>
>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>> ---
>>>  arch/x86/Kconfig | 1 +
>>>  1 file changed, 1 insertion(+)
>>>
>>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>>> index d8983df5a2bc..ebdeb48e4a4a 100644
>>> --- a/arch/x86/Kconfig
>>> +++ b/arch/x86/Kconfig
>>> @@ -30,6 +30,7 @@ config X86_64
>>>  	select MODULES_USE_ELF_RELA
>>>  	select X86_DEV_DMA_OPS
>>>  	select ARCH_HAS_SYSCALL_WRAPPER
>>> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>> 
>> I'd suggest merging this patch with the one making changes to the
>> architectural fault handler towards the end of the series.
>> 
>> The Kconfig change is closely tied to the architectural support for SPF
>> and makes sense to be in a single patch.
>> 
>> If there's a good reason to keep them as separate patches, please move
>> the architecture Kconfig changes after the patch adding fault handler
>> changes.
>> 
>> It's better to enable the feature once the core infrastructure is merged
>> rather than at the beginning of the series to avoid potential bad
>> fallout from incomplete functionality during bisection.
>
> Indeed bisection was the reason why Andrew asked me to push the configuration
> enablement on top of the series (https://lkml.org/lkml/2017/10/10/1229).

The config options have gone through another round of splitting (between
core and architecture) since that comment. I agree that it still makes
sense to define the core config - CONFIG_SPECULATIVE_PAGE_FAULT early
on.

Just to clarify, my suggestion was to only move the architecture configs
further down.

>
> I also think it would be better to have the architecture enablement in on patch
> but that would mean that the code will not be build when bisecting without the
> latest patch adding the per architecture code.

I don't see that as a problem. But if I'm in the minority, I am OK with
leaving things as they are as well.

Thanks,
Punit
