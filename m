Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFE46B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 18:01:44 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so33491108pgi.4
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 15:01:44 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0072.outbound.protection.outlook.com. [104.47.34.72])
        by mx.google.com with ESMTPS id a62si2919875pgc.371.2017.02.28.15.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Feb 2017 15:01:43 -0800 (PST)
Subject: Re: [RFC PATCH v4 05/28] x86: Add Secure Memory Encryption (SME)
 support
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154307.19244.72895.stgit@tlendack-t1.amdoffice.net>
 <20170225152931.p4lws753myepkkb3@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <9ea3d871-e4ae-2408-1bd0-9820cc5826d6@amd.com>
Date: Tue, 28 Feb 2017 17:01:36 -0600
MIME-Version: 1.0
In-Reply-To: <20170225152931.p4lws753myepkkb3@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/25/2017 9:29 AM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:43:07AM -0600, Tom Lendacky wrote:
>> Add support for Secure Memory Encryption (SME). This initial support
>> provides a Kconfig entry to build the SME support into the kernel and
>> defines the memory encryption mask that will be used in subsequent
>> patches to mark pages as encrypted.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> ...
>
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -0,0 +1,42 @@
>> +/*
>> + * AMD Memory Encryption Support
>> + *
>> + * Copyright (C) 2016 Advanced Micro Devices, Inc.
>> + *
>> + * Author: Tom Lendacky <thomas.lendacky@amd.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2 as
>> + * published by the Free Software Foundation.
>> + */
>> +
>> +#ifndef __X86_MEM_ENCRYPT_H__
>> +#define __X86_MEM_ENCRYPT_H__
>> +
>> +#ifndef __ASSEMBLY__
>> +
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>> +
>> +extern unsigned long sme_me_mask;
>> +
>> +static inline bool sme_active(void)
>> +{
>> +	return (sme_me_mask) ? true : false;
>
> 	return !!sme_me_mask;

Done.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
