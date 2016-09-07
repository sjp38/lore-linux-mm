Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57F076B0260
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 10:03:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id k83so40138726pfa.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 07:03:58 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0082.outbound.protection.outlook.com. [104.47.34.82])
        by mx.google.com with ESMTPS id i23si20683319pfj.25.2016.09.07.07.03.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 07:03:57 -0700 (PDT)
Subject: Re: [RFC PATCH v2 03/20] x86: Secure Memory Encryption (SME) build
 enablement
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223559.29880.1502.stgit@tlendack-t1.amdoffice.net>
 <20160902110351.GA22559@nazgul.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5a8e2455-ef08-9e3f-2847-082fd3e01e67@amd.com>
Date: Wed, 7 Sep 2016 09:03:46 -0500
MIME-Version: 1.0
In-Reply-To: <20160902110351.GA22559@nazgul.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/02/2016 06:03 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:35:59PM -0500, Tom Lendacky wrote:
>> Provide the Kconfig support to build the SME support in the kernel.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/Kconfig |    9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index c580d8c..131f329 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1357,6 +1357,15 @@ config X86_DIRECT_GBPAGES
>>  	  supports them), so don't confuse the user by printing
>>  	  that we have them enabled.
>>  
>> +config AMD_MEM_ENCRYPT
>> +	bool "Secure Memory Encryption support for AMD"
> 
> 	     "AMD Secure Memory Encryption support"

Ok.

Thanks,
Tom

> 
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
