Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46E838E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 16:53:57 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id 49so1335205wra.14
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 13:53:57 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::4])
        by mx.google.com with ESMTPS id a130si2111866wma.94.2018.12.13.13.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 13:53:55 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <1ecb7692-f3fb-a246-91f9-2db1b9496305@xenosoft.de>
 <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de>
 <4cfb3f26-74e1-db01-b014-759f188bb5a6@xenosoft.de>
 <82879d3f-83de-6438-c1d6-49c571dcb671@xenosoft.de>
 <20181212141556.GA4801@lst.de>
 <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
 <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de>
 <20181213091021.GA2106@lst.de>
 <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de>
 <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
 <20181213112511.GA4574@lst.de>
 <e109de27-f4af-147d-dc0e-067c8bafb29b@xenosoft.de>
 <ad5a5a8a-d232-d523-a6f7-e9377fc3857b@xenosoft.de>
Message-ID: <e60d6ca3-860c-f01d-8860-c5e022ec7179@xenosoft.de>
Date: Thu, 13 Dec 2018 22:53:47 +0100
MIME-Version: 1.0
In-Reply-To: <ad5a5a8a-d232-d523-a6f7-e9377fc3857b@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On 13 December 2018 at 6:48PM, Christian Zigotzky wrote:
> On 13 December 2018 at 2:34PM, Christian Zigotzky wrote:
>> On 13 December 2018 at 12:25PM, Christoph Hellwig wrote:
>>> On Thu, Dec 13, 2018 at 12:19:26PM +0100, Christian Zigotzky wrote:
>>>> I tried it again but I get the following error message:
>>>>
>>>> MODPOST vmlinux.o
>>>> arch/powerpc/kernel/dma-iommu.o: In function 
>>>> `.dma_iommu_get_required_mask':
>>>> (.text+0x274): undefined reference to `.dma_direct_get_required_mask'
>>>> make: *** [vmlinux] Error 1
>>> Sorry, you need this one liner before all the patches posted last time:
>>>
>>> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
>>> index d8819e3a1eb1..7e78c2798f2f 100644
>>> --- a/arch/powerpc/Kconfig
>>> +++ b/arch/powerpc/Kconfig
>>> @@ -154,6 +154,7 @@ config PPC
>>>       select CLONE_BACKWARDS
>>>       select DCACHE_WORD_ACCESS        if PPC64 && CPU_LITTLE_ENDIAN
>>>       select DYNAMIC_FTRACE            if FUNCTION_TRACER
>>> +    select DMA_DIRECT_OPS
>>>       select EDAC_ATOMIC_SCRUB
>>>       select EDAC_SUPPORT
>>>       select GENERIC_ATOMIC64            if PPC32
>>>
>> Thanks. Result: PASEMI onboard ethernet works and the X5000 (P5020 
>> board) boots with the patch '0001-get_required_mask.patch'.
>>
>> -- Christian
>>
>>
> Next patch: '0002-swiotlb-dma_supported.patch' for the last good 
> commit (977706f9755d2d697aa6f45b4f9f0e07516efeda).
>
> The PASEMI onboard ethernet works and the X5000 (P5020 board) boots.
>
> -- Christian
>
>
Next patch: '0003-nommu-dma_supported.patch'

No problems with the PASEMI onboard ethernet and the P5020 board boots.

-- Christian
