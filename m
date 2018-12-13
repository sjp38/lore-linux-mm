Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECDE8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 03:41:57 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id y7so526932wrr.12
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 00:41:57 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::11])
        by mx.google.com with ESMTPS id e9si750685wrd.451.2018.12.13.00.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 00:41:55 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <1948cf84-49ab-543c-472c-d18e27751903@xenosoft.de>
 <5a2ea855-b4b0-e48a-5c3e-c859a8451ca2@xenosoft.de>
 <7B6DDB28-8BF6-4589-84ED-F1D4D13BFED6@xenosoft.de>
 <8a2c4581-0c85-8065-f37e-984755eb31ab@xenosoft.de>
 <424bb228-c9e5-6593-1ab7-5950d9b2bd4e@xenosoft.de>
 <c86d76b4-b199-557e-bc64-4235729c1e72@xenosoft.de>
 <1ecb7692-f3fb-a246-91f9-2db1b9496305@xenosoft.de>
 <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de>
 <4cfb3f26-74e1-db01-b014-759f188bb5a6@xenosoft.de>
 <82879d3f-83de-6438-c1d6-49c571dcb671@xenosoft.de>
 <20181212141556.GA4801@lst.de>
 <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
Message-ID: <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de>
Date: Thu, 13 Dec 2018 09:41:50 +0100
MIME-Version: 1.0
In-Reply-To: <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On 12 December 2018 at 3:39PM, Christian Zigotzky wrote:
> Hi Christoph,
>
> Thanks a lot for your reply. I will test your patches tomorrow.
>
> Cheers,
> Christian
>
> Sent from my iPhone
>
>> On 12. Dec 2018, at 15:15, Christoph Hellwig <hch@lst.de> wrote:
>>
>> Thanks for bisecting.  I've spent some time going over the conversion
>> but can't really pinpoint it.  I have three little patches that switch
>> parts of the code to the generic version.  This is on top of the
>> last good commmit (977706f9755d2d697aa6f45b4f9f0e07516efeda).
>>
>> Can you check with whіch one things stop working?
>>
>>
>> <0001-get_required_mask.patch>
>> <0002-swiotlb-dma_supported.patch>
>> <0003-nommu-dma_supported.patch>
>> <0004-alloc-free.patch>

Today I tried the first patch (0001-get_required_mask.patch) with the 
last good commit (977706f9755d2d697aa6f45b4f9f0e07516efeda). 
Unfortunately this patch is already included in the last good commit 
(977706f9755d2d697aa6f45b4f9f0e07516efeda). I will try the next patch.

-- Christian
