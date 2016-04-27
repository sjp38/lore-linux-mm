Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68C3E6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:21:06 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so78722032pad.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 09:21:06 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0098.outbound.protection.outlook.com. [157.56.111.98])
        by mx.google.com with ESMTPS id q79si4765816pfi.230.2016.04.27.09.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 09:21:05 -0700 (PDT)
Subject: Re: [RFC PATCH v1 03/18] x86: Secure Memory Encryption (SME) support
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225626.13567.72425.stgit@tlendack-t1.amdoffice.net>
 <20160322130354.GC16528@xo-6d-61-c0.localdomain>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5720E6E9.30900@amd.com>
Date: Wed, 27 Apr 2016 11:20:57 -0500
MIME-Version: 1.0
In-Reply-To: <20160322130354.GC16528@xo-6d-61-c0.localdomain>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 03/22/2016 08:03 AM, Pavel Machek wrote:
> On Tue 2016-04-26 17:56:26, Tom Lendacky wrote:
>> Provide support for Secure Memory Encryption (SME). This initial support
>> defines the memory encryption mask as a variable for quick access and an
>> accessor for retrieving the number of physical addressing bits lost if
>> SME is enabled.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/mem_encrypt.h |   37 ++++++++++++++++++++++++++++++++++++
>>  arch/x86/kernel/Makefile           |    2 ++
>>  arch/x86/kernel/mem_encrypt.S      |   29 ++++++++++++++++++++++++++++
>>  arch/x86/kernel/x8664_ksyms_64.c   |    6 ++++++
>>  4 files changed, 74 insertions(+)
>>  create mode 100644 arch/x86/include/asm/mem_encrypt.h
>>  create mode 100644 arch/x86/kernel/mem_encrypt.S
>>
>> index 0000000..ef7f325
>> --- /dev/null
>> +++ b/arch/x86/kernel/mem_encrypt.S
>> @@ -0,0 +1,29 @@
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
>> +#include <linux/linkage.h>
>> +
>> +	.text
>> +	.code64
>> +ENTRY(sme_get_me_loss)
>> +	xor	%rax, %rax
>> +	mov	sme_me_loss(%rip), %al
>> +	ret
>> +ENDPROC(sme_get_me_loss)
> 
> Does this really need to be implemented in assembly?

That particular routine probably doesn't need to be in assembly. But
since it was such a simple routine I put it there because a later
patch derives the value in this file.

Thanks,
Tom

> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
