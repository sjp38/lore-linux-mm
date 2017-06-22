Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7156B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:48:57 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o41so8572542qtf.8
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 09:48:57 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0081.outbound.protection.outlook.com. [104.47.33.81])
        by mx.google.com with ESMTPS id p27si48732qtg.225.2017.06.22.09.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 09:48:56 -0700 (PDT)
Subject: Re: [PATCH v7 27/36] iommu/amd: Allow the AMD IOMMU to work with
 memory encryption
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185459.18967.72790.stgit@tlendack-t1.amdoffice.net>
 <20170622105637.g7twdaae2v5eaown@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <379702e6-31f1-2df1-8889-3498241aea49@amd.com>
Date: Thu, 22 Jun 2017 11:48:46 -0500
MIME-Version: 1.0
In-Reply-To: <20170622105637.g7twdaae2v5eaown@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On 6/22/2017 5:56 AM, Borislav Petkov wrote:
> On Fri, Jun 16, 2017 at 01:54:59PM -0500, Tom Lendacky wrote:
>> The IOMMU is programmed with physical addresses for the various tables
>> and buffers that are used to communicate between the device and the
>> driver. When the driver allocates this memory it is encrypted. In order
>> for the IOMMU to access the memory as encrypted the encryption mask needs
>> to be included in these physical addresses during configuration.
>>
>> The PTE entries created by the IOMMU should also include the encryption
>> mask so that when the device behind the IOMMU performs a DMA, the DMA
>> will be performed to encrypted memory.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   drivers/iommu/amd_iommu.c       |   30 ++++++++++++++++--------------
>>   drivers/iommu/amd_iommu_init.c  |   34 ++++++++++++++++++++++++++++------
>>   drivers/iommu/amd_iommu_proto.h |   10 ++++++++++
>>   drivers/iommu/amd_iommu_types.h |    2 +-
>>   4 files changed, 55 insertions(+), 21 deletions(-)
> 
> Reviewed-by: Borislav Petkov <bp@suse.de>
> 
> Btw, I'm assuming the virt_to_phys() difference on SME systems is only
> needed in a handful of places. Otherwise, I'd suggest changing the
> virt_to_phys() function/macro directly. But I guess most of the places
> need the real physical address without the enc bit.

Correct.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
