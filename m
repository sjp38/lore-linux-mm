Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9BC8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 06:19:35 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v16so288142wru.8
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 03:19:35 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::12])
        by mx.google.com with ESMTPS id t11si1305502wmt.146.2018.12.13.03.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 03:19:33 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <8a2c4581-0c85-8065-f37e-984755eb31ab@xenosoft.de>
 <424bb228-c9e5-6593-1ab7-5950d9b2bd4e@xenosoft.de>
 <c86d76b4-b199-557e-bc64-4235729c1e72@xenosoft.de>
 <1ecb7692-f3fb-a246-91f9-2db1b9496305@xenosoft.de>
 <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de>
 <4cfb3f26-74e1-db01-b014-759f188bb5a6@xenosoft.de>
 <82879d3f-83de-6438-c1d6-49c571dcb671@xenosoft.de>
 <20181212141556.GA4801@lst.de>
 <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
 <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de>
 <20181213091021.GA2106@lst.de>
 <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de>
Message-ID: <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
Date: Thu, 13 Dec 2018 12:19:26 +0100
MIME-Version: 1.0
In-Reply-To: <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On 13 December 2018 at 10:47AM, Christian Zigotzky wrote:
> On 13 December 2018 at 10:10AM, Christoph Hellwig wrote:
>> On Thu, Dec 13, 2018 at 09:41:50AM +0100, Christian Zigotzky wrote:
>>> Today I tried the first patch (0001-get_required_mask.patch) with 
>>> the last
>>> good commit (977706f9755d2d697aa6f45b4f9f0e07516efeda). 
>>> Unfortunately this
>>> patch is already included in the last good commit
>>> (977706f9755d2d697aa6f45b4f9f0e07516efeda). I will try the next patch.
>> Hmm, I don't think this is the case.  This is my local git log output:
>>
>> commit 83a4b87de6bc6a75b500c9959de88e2157fbcd7c
>> Author: Christoph Hellwig <hch@lst.de>
>> Date:   Wed Dec 12 15:07:49 2018 +0100
>>
>>      get_required_mask
>>
>> commit 977706f9755d2d697aa6f45b4f9f0e07516efeda
>> Author: Christoph Hellwig <hch@lst.de>
>> Date:   Sat Nov 10 22:34:27 2018 +0100
>>
>>      powerpc/dma: remove dma_nommu_mmap_coherent
>>
>> I've also pushed a git branch with these out to:
>>
>>      git://git.infradead.org/users/hch/misc.git powerpc-dma.5-debug
>>
> Sorry Christioph. I was wrong. The first patch isn't included in the 
> last good commit. I will try it again. I can only test beside my main 
> work. That means it takes longer.
>
> -- Christian
>
>
I tried it again but I get the following error message:

MODPOST vmlinux.o
arch/powerpc/kernel/dma-iommu.o: In function `.dma_iommu_get_required_mask':
(.text+0x274): undefined reference to `.dma_direct_get_required_mask'
make: *** [vmlinux] Error 1
