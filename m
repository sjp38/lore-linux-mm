Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA6AF8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:49:29 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id o6so646680wmf.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:49:29 -0800 (PST)
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::3])
        by mx.google.com with ESMTPS id c16si12439989wml.0.2019.01.15.00.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 00:49:28 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
 <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de>
 <20181213091021.GA2106@lst.de>
 <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de>
 <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
 <20181213112511.GA4574@lst.de>
 <e109de27-f4af-147d-dc0e-067c8bafb29b@xenosoft.de>
 <ad5a5a8a-d232-d523-a6f7-e9377fc3857b@xenosoft.de>
 <e60d6ca3-860c-f01d-8860-c5e022ec7179@xenosoft.de>
 <008c981e-bdd2-21a7-f5f7-c57e4850ae9a@xenosoft.de>
 <20190103073622.GA24323@lst.de>
 <71A251A5-FA06-4019-B324-7AED32F7B714@xenosoft.de>
 <1b0c5c21-2761-d3a3-651b-3687bb6ae694@xenosoft.de>
 <3504ee70-02de-049e-6402-2d530bf55a84@xenosoft.de>
 <23284859-bf0a-9cd5-a480-2a7fd7802056@xenosoft.de>
 <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de>
 <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de>
Message-ID: <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de>
Date: Tue, 15 Jan 2019 09:49:22 +0100
MIME-Version: 1.0
In-Reply-To: <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Next step: 63a6e350e037a21e9a88c8b710129bea7049a80f (powerpc/dma: use 
the dma_direct mapping routines)

git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a

git checkout 63a6e350e037a21e9a88c8b710129bea7049a80f

Error message:

arch/powerpc/kernel/dma.o:(.data.rel.ro+0x0): undefined reference to 
`__dma_nommu_alloc_coherent'
arch/powerpc/kernel/dma.o:(.data.rel.ro+0x8): undefined reference to 
`__dma_nommu_free_coherent'
Makefile:1027: recipe for target 'vmlinux' failed
make: *** [vmlinux] Error 1

-- Christian


On 15 January 2019 at 09:07AM, Christian Zigotzky wrote:
> Next step: 240d7ecd7f6fa62e074e8a835e620047954f0b28 (powerpc/dma: use 
> the dma-direct allocator for coherent platforms)
>
> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>
> git checkout 240d7ecd7f6fa62e074e8a835e620047954f0b28
>
> Link to the Git: 
> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>
> env LANG=C make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc zImage
>
> Error message:
>
> arch/powerpc/kernel/dma.o:(.data.rel.ro+0x0): undefined reference to 
> `__dma_nommu_alloc_coherent'
> arch/powerpc/kernel/dma.o:(.data.rel.ro+0x8): undefined reference to 
> `__dma_nommu_free_coherent'
> Makefile:1027: recipe for target 'vmlinux' failed
> make: *** [vmlinux] Error 1
>
> -- Christian
>
>
> On 12 January 2019 at 7:14PM, Christian Zigotzky wrote:
>> Next step: 4558b6e1ddf3dcf5a86d6a5d16c2ac1600c7df39 (swiotlb: remove 
>> swiotlb_dma_supported)
>>
>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>
>> git checkout 4558b6e1ddf3dcf5a86d6a5d16c2ac1600c7df39
>>
>> Output:
>>
>> You are in 'detached HEAD' state. You can look around, make experimental
>> changes and commit them, and you can discard any commits you make in 
>> this
>> state without impacting any branches by performing another checkout.
>>
>> If you want to create a new branch to retain commits you create, you may
>> do so (now or later) by using -b with the checkout command again. 
>> Example:
>>
>>   git checkout -b <new-branch-name>
>>
>> HEAD is now at 4558b6e... swiotlb: remove swiotlb_dma_supported
>>
>> ----
>>
>> Link to the Git: 
>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>
>> Results: PASEMI onboard ethernet (X1000) works and the X5000 (P5020 
>> board) boots. I also successfully tested sound, hardware 3D 
>> acceleration, Bluetooth, network, booting with a label etc. The 
>> uImages work also in a virtual e5500 quad-core QEMU machine.
>>
>> -- Christian
>>
>>
>> On 11 January 2019 at 03:10AM, Christian Zigotzky wrote:
>>> Next step: 891dcc1072f1fa27a83da920d88daff6ca08fc02 (powerpc/dma: 
>>> remove dma_nommu_dma_supported)
>>>
>>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>>
>>> git checkout 891dcc1072f1fa27a83da920d88daff6ca08fc02
>>>
>>> Output:
>>>
>>> Note: checking out '891dcc1072f1fa27a83da920d88daff6ca08fc02'.
>>>
>>> You are in 'detached HEAD' state. You can look around, make 
>>> experimental
>>> changes and commit them, and you can discard any commits you make in 
>>> this
>>> state without impacting any branches by performing another checkout.
>>>
>>> If you want to create a new branch to retain commits you create, you 
>>> may
>>> do so (now or later) by using -b with the checkout command again. 
>>> Example:
>>>
>>> git checkout -b <new-branch-name>
>>>
>>> HEAD is now at 891dcc1... powerpc/dma: remove dma_nommu_dma_supported
>>>
>>> ---
>>>
>>> Link to the Git: 
>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>
>>> Results: PASEMI onboard ethernet works and the X5000 (P5020 board) 
>>> boots. I also successfully tested sound, hardware 3D acceleration, 
>>> Bluetooth, network, booting with a label etc. The uImages work also 
>>> in a virtual e5500 quad-core QEMU machine.
>>>
>>> -- Christian
>>>
>>>
>>> On 09 January 2019 at 10:31AM, Christian Zigotzky wrote:
>>>> Next step: a64e18ba191ba9102fb174f27d707485ffd9389c (powerpc/dma: 
>>>> remove dma_nommu_get_required_mask)
>>>>
>>>> git clone git://git.infradead.org/users/hch/misc.git -b 
>>>> powerpc-dma.6 a
>>>>
>>>> git checkout a64e18ba191ba9102fb174f27d707485ffd9389c
>>>>
>>>> Link to the Git: 
>>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>>
>>>> Results: PASEMI onboard ethernet works and the X5000 (P5020 board) 
>>>> boots. I also successfully tested sound, hardware 3D acceleration, 
>>>> Bluetooth, network, booting with a label etc. The uImages work also 
>>>> in a virtual e5500 quad-core QEMU machine.
>>>>
>>>> -- Christian
>>>>
>>>>
>>>> On 05 January 2019 at 5:03PM, Christian Zigotzky wrote:
>>>>> Next step: c446404b041130fbd9d1772d184f24715cf2362f (powerpc/dma: 
>>>>> remove dma_nommu_mmap_coherent)
>>>>>
>>>>> git clone git://git.infradead.org/users/hch/misc.git -b 
>>>>> powerpc-dma.6 a
>>>>>
>>>>> git checkout c446404b041130fbd9d1772d184f24715cf2362f
>>>>>
>>>>> Output:
>>>>>
>>>>> Note: checking out 'c446404b041130fbd9d1772d184f24715cf2362f'.
>>>>>
>>>>> You are in 'detached HEAD' state. You can look around, make 
>>>>> experimental
>>>>> changes and commit them, and you can discard any commits you make 
>>>>> in this
>>>>> state without impacting any branches by performing another checkout.
>>>>>
>>>>> If you want to create a new branch to retain commits you create, 
>>>>> you may
>>>>> do so (now or later) by using -b with the checkout command again. 
>>>>> Example:
>>>>>
>>>>>   git checkout -b <new-branch-name>
>>>>>
>>>>> HEAD is now at c446404... powerpc/dma: remove dma_nommu_mmap_coherent
>>>>>
>>>>> -----
>>>>>
>>>>> Link to the Git: 
>>>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>>>
>>>>> Result: PASEMI onboard ethernet works and the X5000 (P5020 board) 
>>>>> boots.
>>>>>
>>>>> -- Christian
>>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>
>
