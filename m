Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 959E56B006C
	for <linux-mm@kvack.org>; Mon, 31 Dec 2012 20:07:50 -0500 (EST)
Received: by mail-ye0-f171.google.com with SMTP id m8so2056559yen.30
        for <linux-mm@kvack.org>; Mon, 31 Dec 2012 17:07:49 -0800 (PST)
Message-ID: <50E236E2.9050305@gmail.com>
Date: Mon, 31 Dec 2012 17:07:46 -0800
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] arm: dma mapping: export arm iommu functions
References: <1356592458-11077-1-git-send-email-prathyush.k@samsung.com> <50DC580C.7080507@samsung.com> <CAH=HWYP5r18qjQSc_2121vikbTMpYv6DKOfW=hpOpGB7rUyNRA@mail.gmail.com> <20121229065356.GA13760@quad.lixom.net>
In-Reply-To: <20121229065356.GA13760@quad.lixom.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: Prathyush K <prathyush@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Prathyush K <prathyush.k@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org



On Friday 28 December 2012 10:53 PM, Olof Johansson wrote:
> On Fri, Dec 28, 2012 at 09:53:47AM +0530, Prathyush K wrote:
>> On Thu, Dec 27, 2012 at 7:45 PM, Marek Szyprowski
>> <m.szyprowski@samsung.com>wrote:
>>
>>> Hello,
>>>
>>>
>>> On 12/27/2012 8:14 AM, Prathyush K wrote:
>>>
>>>> This patch adds EXPORT_SYMBOL calls to the three arm iommu
>>>> functions - arm_iommu_create_mapping, arm_iommu_free_mapping
>>>> and arm_iommu_attach_device. These functions can now be called
>>>> from dynamic modules.
>>>>
>>>
>>> Could You describe a bit more why those functions might be needed by
>>> dynamic modules?
>>>
>>> Hi Marek,
>>
>> We are adding iommu support to exynos gsc and s5p-mfc.
>> And these two drivers need to be built as modules to improve boot time.
>>
>> We're calling these three functions from inside these drivers:
>> e.g.
>> mapping = arm_iommu_create_mapping(&platform_bus_type, 0x20000000, SZ_256M,
>> 4);
>> arm_iommu_attach_device(mdev, mapping);
>
> The driver shouldn't have to call these low-level functions directly,
> something's wrong if you need that.

These are not truly low-level calls, but arm specific wrappers to the 
dma-mapping implementations. Drivers need to call former to declare 
mappings requirement needed for their IOMMU and later to start using it.

>
> How is the DMA address management different here from other system/io mmus? is
> that 256M window a hardware restriction?

No, each IOMMU is capable of 4G. But to keep the IOMMU address space to 
what is required, various sizes were used earlier and later fixed on to 
256M. This can be increased if the drivers demand more buffers mapped to 
the device at anytime.


Regards,
Subash

>
> -Olof
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
