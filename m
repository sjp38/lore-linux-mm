Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE9C6B02C3
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 10:02:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e199so20684162pfh.7
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 07:02:22 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0064.outbound.protection.outlook.com. [104.47.36.64])
        by mx.google.com with ESMTPS id d70si1876193pgc.211.2017.07.18.07.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Jul 2017 07:02:20 -0700 (PDT)
Subject: Re: [PATCH v10 00/38] x86: Secure Memory Encryption (AMD)
References: <cover.1500319216.git.thomas.lendacky@amd.com>
 <alpine.DEB.2.20.1707181402340.1945@nanos>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <d43d315c-6797-b51e-58a8-05b5f98951d0@amd.com>
Date: Tue, 18 Jul 2017 09:02:08 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707181402340.1945@nanos>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, iommu@lists.linux-foundation.org, Joerg Roedel <joro@8bytes.org>, kexec@lists.infradead.org, xen-devel@lists.xen.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>

On 7/18/2017 7:03 AM, Thomas Gleixner wrote:
> On Mon, 17 Jul 2017, Tom Lendacky wrote:
>> This patch series provides support for AMD's new Secure Memory Encryption (SME)
>> feature.
>>
>> SME can be used to mark individual pages of memory as encrypted through the
>> page tables. A page of memory that is marked encrypted will be automatically
>> decrypted when read from DRAM and will be automatically encrypted when
>> written to DRAM. Details on SME can found in the links below.
>>
>> The SME feature is identified through a CPUID function and enabled through
>> the SYSCFG MSR. Once enabled, page table entries will determine how the
>> memory is accessed. If a page table entry has the memory encryption mask set,
>> then that memory will be accessed as encrypted memory. The memory encryption
>> mask (as well as other related information) is determined from settings
>> returned through the same CPUID function that identifies the presence of the
>> feature.
>>
>> The approach that this patch series takes is to encrypt everything possible
>> starting early in the boot where the kernel is encrypted. Using the page
>> table macros the encryption mask can be incorporated into all page table
>> entries and page allocations. By updating the protection map, userspace
>> allocations are also marked encrypted. Certain data must be accounted for
>> as having been placed in memory before SME was enabled (EFI, initrd, etc.)
>> and accessed accordingly.
>>
>> This patch series is a pre-cursor to another AMD processor feature called
>> Secure Encrypted Virtualization (SEV). The support for SEV will build upon
>> the SME support and will be submitted later. Details on SEV can be found
>> in the links below.
> 
> Well done series. Thanks to all people involved, especially Tom and Boris!
> It was a pleasure to review that.
> 
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

A big thanks from me to everyone that helped review this.  I truly
appreciate all the time that everyone put into this - especially Boris,
who helped guide this series from the start.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
