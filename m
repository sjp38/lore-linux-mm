Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE6466B0260
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:17:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so89837551pfy.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:17:45 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0074.outbound.protection.outlook.com. [157.56.111.74])
        by mx.google.com with ESMTPS id hy8si5800964pab.190.2016.04.27.08.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 08:17:44 -0700 (PDT)
Subject: Re: [RFC PATCH v1 02/18] x86: Secure Memory Encryption (SME) build
 enablement
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225614.13567.47487.stgit@tlendack-t1.amdoffice.net>
 <20160322130150.GB16528@xo-6d-61-c0.localdomain>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5720D810.9060602@amd.com>
Date: Wed, 27 Apr 2016 10:17:36 -0500
MIME-Version: 1.0
In-Reply-To: <20160322130150.GB16528@xo-6d-61-c0.localdomain>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 03/22/2016 08:01 AM, Pavel Machek wrote:
> On Tue 2016-04-26 17:56:14, Tom Lendacky wrote:
>> Provide the Kconfig support to build the SME support in the kernel.
> 
> 
> Probably should go last in the series?

Yeah, I've seen arguments both ways for this. Doing it early
allows compiling and testing with it enabled and doing it late
doesn't enable anything until it's all there. I just chose the
former.

Thanks,
Tom

> 
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/Kconfig |    9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 7bb1574..13249b5 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1356,6 +1356,15 @@ config X86_DIRECT_GBPAGES
>>  	  supports them), so don't confuse the user by printing
>>  	  that we have them enabled.
>>  
>> +config AMD_MEM_ENCRYPT
>> +	bool "Secure Memory Encryption support for AMD"
>> +	depends on X86_64 && CPU_SUP_AMD
>> +	---help---
>> +	  Say yes to enable the encryption of system memory. This requires
>> +	  an AMD processor that supports Secure Memory Encryption (SME).
>> +	  The encryption of system memory is disabled by default but can be
>> +	  enabled with the mem_encrypt=on command line option.
>> +
>>  # Common NUMA Features
>>  config NUMA
>>  	bool "Numa Memory Allocation and Scheduler Support"
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
