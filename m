Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDF036B0388
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:27:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o74so158852900pfi.6
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:27:02 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0088.outbound.protection.outlook.com. [104.47.42.88])
        by mx.google.com with ESMTPS id v7si3327871pgo.468.2017.06.21.06.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 06:27:01 -0700 (PDT)
Subject: Re: [PATCH v7 06/36] x86/mm: Add Secure Memory Encryption (SME)
 support
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185054.18967.52228.stgit@tlendack-t1.amdoffice.net>
 <alpine.DEB.2.20.1706202244480.2157@nanos>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <efa51470-5d8f-6883-b9da-f2face12ea22@amd.com>
Date: Wed, 21 Jun 2017 08:26:44 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706202244480.2157@nanos>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Paolo Bonzini <pbonzini@redhat.com>

On 6/20/2017 3:49 PM, Thomas Gleixner wrote:
> On Fri, 16 Jun 2017, Tom Lendacky wrote:
>>   
>> +config ARCH_HAS_MEM_ENCRYPT
>> +	def_bool y
>> +	depends on X86
> 
> That one is silly. The config switch is in the x86 KConfig file, so X86 is
> on. If you intended to move this to some generic place outside of
> x86/Kconfig then this should be
> 
> config ARCH_HAS_MEM_ENCRYPT
> 	bool
> 
> and x86/Kconfig should have
> 
>      	select ARCH_HAS_MEM_ENCRYPT
> 
> and that should be selected by AMD_MEM_ENCRYPT

This is used for deciding whether to include the asm/mem_encrypt.h file
so it needs to be on whether AMD_MEM_ENCRYPT is configured or not. I'll
leave it in the x86/Kconfig file and remove the depends on line.

Thanks,
Tom

> 
>> +config AMD_MEM_ENCRYPT
>> +	bool "AMD Secure Memory Encryption (SME) support"
>> +	depends on X86_64 && CPU_SUP_AMD
>> +	---help---
>> +	  Say yes to enable support for the encryption of system memory.
>> +	  This requires an AMD processor that supports Secure Memory
>> +	  Encryption (SME).
> 
> Thanks,
> 
> 	tglx
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
