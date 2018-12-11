Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C46B18E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:28:54 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 129so740817wmy.7
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:28:54 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::6])
        by mx.google.com with ESMTPS id f12si9345413wrm.349.2018.12.11.06.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 06:28:53 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <20181129170351.GC27951@lst.de>
 <d0e04a85-f17d-414e-6fea-971414417430@xenosoft.de>
 <20181130105346.GB26765@lst.de>
 <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de>
 <20181130131056.GA5211@lst.de>
 <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de>
 <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de>
 <58c61afb-290f-6196-c72c-ac7b61b84718@xenosoft.de>
 <20181204142426.GA2743@lst.de>
 <ef56d279-f75d-008e-71ba-7068c1b37c48@xenosoft.de>
 <20181205140550.GA27549@lst.de>
 <1948cf84-49ab-543c-472c-d18e27751903@xenosoft.de>
 <5a2ea855-b4b0-e48a-5c3e-c859a8451ca2@xenosoft.de>
 <7B6DDB28-8BF6-4589-84ED-F1D4D13BFED6@xenosoft.de>
 <8a2c4581-0c85-8065-f37e-984755eb31ab@xenosoft.de>
 <424bb228-c9e5-6593-1ab7-5950d9b2bd4e@xenosoft.de>
 <c86d76b4-b199-557e-bc64-4235729c1e72@xenosoft.de>
 <1ecb7692-f3fb-a246-91f9-2db1b9496305@xenosoft.de>
 <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de>
Message-ID: <4cfb3f26-74e1-db01-b014-759f188bb5a6@xenosoft.de>
Date: Tue, 11 Dec 2018 15:28:47 +0100
MIME-Version: 1.0
In-Reply-To: <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Next step: 977706f9755d2d697aa6f45b4f9f0e07516efeda (powerpc/dma: remove 
dma_nommu_mmap_coherent)

Result: The P5020 board boots and the PASEMI onboard ethernet works.

-- Christian


On 10 December 2018 at 4:54PM, Christian Zigotzky wrote:
> Next step: 64ecd2c160bbef31465c4d34efc0f076a2aad4df (powerpc/dma: use 
> phys_to_dma instead of get_dma_offset)
>
> The P5020 board boots and the PASEMI onboard ethernet works.
>
> -- Christian
>
>
> On 09 December 2018 at 7:26PM, Christian Zigotzky wrote:
>> Next step: c1bfcad4b0cf38ce5b00f7ad880d3a13484c123a (dma-mapping, 
>> powerpc: simplify the arch dma_set_mask override)
>>
>> Result: No problems with the PASEMI onboard ethernet and with booting 
>> the X5000 (P5020 board).
>>
>> -- Christian
>>
>>
>> On 09 December 2018 at 3:20PM, Christian Zigotzky wrote:
>>> Next step: 602307b034734ce77a05da4b99333a2eaf6b6482 
>>> (powerpc/fsl_pci: simplify fsl_pci_dma_set_mask)
>>>
>>> git checkout 602307b034734ce77a05da4b99333a2eaf6b6482
>>>
>>> The PASEMI onboard ethernet works and the X5000 boots.
>>>
>>> -- Christian
>>>
>>>
>>> On 08 December 2018 at 2:47PM, Christian Zigotzky wrote:
>>>> Next step: e15cd8173ef85e9cc3e2a9c7cc2982f5c1355615 (powerpc/dma: 
>>>> fix an off-by-one in dma_capable)
>>>>
>>>> git checkout e15cd8173ef85e9cc3e2a9c7cc2982f5c1355615
>>>>
>>>> The PASEMI onboard ethernet also works with this commit and the 
>>>> X5000 boots without any problems.
>>>>
>>>> -- Christian
>>>>
>>>>
>>>> On 08 December 2018 at 11:29AM, Christian Zigotzky wrote:
>>>>> Next step: 7ebc44c535f6bd726d553756d38b137acc718443 (powerpc/dma: 
>>>>> remove max_direct_dma_addr)
>>>>>
>>>>> git checkout 7ebc44c535f6bd726d553756d38b137acc718443
>>>>>
>>>>> OK, the PASEMI onboard ethernet works and the P5020 board boots.
>>>>>
>>>>> -- Christian
>>>>>
>>>>>
>>>>> On 07 December 2018 at 7:33PM, Christian Zigotzky wrote:
>>>>>> Next step: 13c1fdec5682b6e13257277fa16aa31f342d167d (powerpc/dma: 
>>>>>> move pci_dma_dev_setup_swiotlb to fsl_pci.c)
>>>>>>
>>>>>> git checkout 13c1fdec5682b6e13257277fa16aa31f342d167d
>>>>>>
>>>>>> Result: The PASEMI onboard ethernet works and the P5020 board boots.
>>>>>>
>>>>>> — Christian
>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>
>
