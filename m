Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29D3E681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:48:18 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y196so52004570ity.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:48:18 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0077.outbound.protection.outlook.com. [104.47.41.77])
        by mx.google.com with ESMTPS id p64si8161599itb.75.2017.02.16.11.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 11:48:17 -0800 (PST)
Subject: Re: [RFC PATCH v4 01/28] x86: Documentation for AMD Secure Memory
 Encryption (SME)
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154211.19244.76656.stgit@tlendack-t1.amdoffice.net>
 <20170216175625.imxsvz7fzvlpveze@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <7dcbe640-4cde-cc28-ab82-2d8517925e93@amd.com>
Date: Thu, 16 Feb 2017 13:48:08 -0600
MIME-Version: 1.0
In-Reply-To: <20170216175625.imxsvz7fzvlpveze@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 02/16/2017 11:56 AM, Borislav Petkov wrote:
> Ok, this time detailed review :-)
> 
> On Thu, Feb 16, 2017 at 09:42:11AM -0600, Tom Lendacky wrote:
>> This patch adds a Documenation entry to decribe the AMD Secure Memory
>> Encryption (SME) feature.
> 
> Please introduce a spellchecker into your patch creation workflow. I see
> two typos in one line.
> 
> Also, never start patch commit messages with "This patch" - we know it
> is this patch. Always write a doer-sentences explaining the why, not the
> what. Something like:
> 
> "Add a SME and mem_encrypt= kernel parameter documentation."
> 
> for example.

Ok, will do.

> 
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  Documentation/admin-guide/kernel-parameters.txt |   11 ++++
>>  Documentation/x86/amd-memory-encryption.txt     |   57 +++++++++++++++++++++++
>>  2 files changed, 68 insertions(+)
>>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
>>
>> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
>> index 110745e..91c40fa 100644
>> --- a/Documentation/admin-guide/kernel-parameters.txt
>> +++ b/Documentation/admin-guide/kernel-parameters.txt
>> @@ -2145,6 +2145,17 @@
>>  			memory contents and reserves bad memory
>>  			regions that are detected.
>>  
>> +	mem_encrypt=	[X86-64] AMD Secure Memory Encryption (SME) control
>> +			Valid arguments: on, off
>> +			Default (depends on kernel configuration option):
>> +			  on  (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y)
>> +			  off (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=n)
>> +			mem_encrypt=on:		Activate SME
>> +			mem_encrypt=off:	Do not activate SME
>> +
>> +			Refer to the SME documentation for details on when
> 
> "Refer to Documentation/x86/amd-memory-encryption.txt .."

Ok.

> 
>> +			memory encryption can be activated.
>> +
>>  	mem_sleep_default=	[SUSPEND] Default system suspend mode:
>>  			s2idle  - Suspend-To-Idle
>>  			shallow - Power-On Suspend or equivalent (if supported)
>> diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
>> new file mode 100644
>> index 0000000..0938e89
>> --- /dev/null
>> +++ b/Documentation/x86/amd-memory-encryption.txt
>> @@ -0,0 +1,57 @@
>> +Secure Memory Encryption (SME) is a feature found on AMD processors.
>> +
>> +SME provides the ability to mark individual pages of memory as encrypted using
>> +the standard x86 page tables.  A page that is marked encrypted will be
>> +automatically decrypted when read from DRAM and encrypted when written to
>> +DRAM.  SME can therefore be used to protect the contents of DRAM from physical
>> +attacks on the system.
>> +
>> +A page is encrypted when a page table entry has the encryption bit set (see
>> +below how to determine the position of the bit).  The encryption bit can be
> 
> "... how to determine its position)."

Ok.

> 
>> +specified in the cr3 register, allowing the PGD table to be encrypted. Each
>> +successive level of page tables can also be encrypted.
>> +
>> +Support for SME can be determined through the CPUID instruction. The CPUID
>> +function 0x8000001f reports information related to SME:
>> +
>> +	0x8000001f[eax]:
>> +		Bit[0] indicates support for SME
>> +	0x8000001f[ebx]:
>> +		Bit[5:0]  pagetable bit number used to activate memory
>> +			  encryption
> 
> s/Bit/Bits/

Ok.

> 
>> +		Bit[11:6] reduction in physical address space, in bits, when
> 
> Ditto.
> 
>> +			  memory encryption is enabled (this only affects system
>> +			  physical addresses, not guest physical addresses)
>> +
>> +If support for SME is present, MSR 0xc00100010 (SYS_CFG) can be used to
> 
> Let's use the kernel's define name MSR_K8_SYSCFG to avoid ambiguity.

Will do.

> 
>> +determine if SME is enabled and/or to enable memory encryption:
>> +
>> +	0xc0010010:
>> +		Bit[23]   0 = memory encryption features are disabled
>> +			  1 = memory encryption features are enabled
>> +
>> +Linux relies on BIOS to set this bit if BIOS has determined that the reduction
>> +in the physical address space as a result of enabling memory encryption (see
>> +CPUID information above) will not conflict with the address space resource
>> +requirements for the system.  If this bit is not set upon Linux startup then
>> +Linux itself will not set it and memory encryption will not be possible.
>> +
>> +The state of SME in the Linux kernel can be documented as follows:
>> +	- Supported:
>> +	  The CPU supports SME (determined through CPUID instruction).
>> +
>> +	- Enabled:
>> +	  Supported and bit 23 of the SYS_CFG MSR is set.
> 
> Ditto.
> 
>> +
>> +	- Active:
>> +	  Supported, Enabled and the Linux kernel is actively applying
>> +	  the encryption bit to page table entries (the SME mask in the
>> +	  kernel is non-zero).
>> +
>> +SME can also be enabled and activated in the BIOS. If SME is enabled and
>> +activated in the BIOS, then all memory accesses will be encrypted and it will
>> +not be necessary to activate the Linux memory encryption support.  If the BIOS
>> +merely enables SME (sets bit 23 of the SYS_CFG MSR), then Linux can activate
>> +memory encryption.
> 
> "... This is done by supplying mem_encrypt=on on the kernel command line.
> Alternatively, if the kernel should enable SME by default, set
> CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y."

Yup, much clearer.

> 
>> However, if BIOS does not enable SME, then Linux will not
>> +attempt to activate memory encryption, even if configured to do so by default
> 
> will not attempt or will not be able to?

Probably closer to will not be able to right now.  I'll update that.

Thanks,
Tom

> 
>> +or the mem_encrypt=on command line parameter is specified.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
