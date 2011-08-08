Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A2152900137
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 11:21:48 -0400 (EDT)
Received: by mail-vw0-f48.google.com with SMTP id 7so4239026vws.7
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 08:21:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQjnOM58AReFuDpcSjHvNP2UZX1ZUeuWyfWCG6Ayxdfj4QE7w@mail.gmail.com>
References: <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
	<000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
	<20110729093555.GA13522@8bytes.org>
	<001901cc4dd8$4afb4e40$e0f1eac0$%szyprowski@samsung.com>
	<20110729105422.GB13522@8bytes.org>
	<004201cc4dfb$47ee4770$d7cad650$%szyprowski@samsung.com>
	<CAHQjnOM58AReFuDpcSjHvNP2UZX1ZUeuWyfWCG6Ayxdfj4QE7w@mail.gmail.com>
Date: Mon, 8 Aug 2011 10:21:46 -0500
Message-ID: <CAB-zwWj-VCWQ6h8wjv7owG7n7p59Ep4qXiQY3LruT64sikuSKg@mail.gmail.com>
Subject: Re: [RFC] ARM: dma_map|unmap_sg plus iommu
From: "Ramirez Luna, Omar" <omar.ramirez@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Joerg Roedel <joro@8bytes.org>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Ohad Ben-Cohen <ohad@wizery.com>

Hi,

On Sun, Jul 31, 2011 at 7:57 PM, KyongHo Cho <pullip.cho@samsung.com> wrote:
> On Fri, Jul 29, 2011 at 11:24 PM, Marek Szyprowski
...
>> Right now I have no idea how to handle this better. Perhaps with should be
>> possible
>> to specify somehow the target dma_address when doing memory allocation, but I'm
>> not
>> really convinced yet if this is really required.
>>
> What about using 'dma_handle' argument of alloc_coherent callback of
> dma_map_ops?
> Although it is an output argument, I think we can convey a hint or
> start address to map
> to the IO memory manager that resides behind dma API.

I also thought on this one, even dma_map_single receives a void *ptr
which could be casted into a struct with both physical and virtual
addresses to be mapped, but IMHO, this starts to add twists into the
dma map parameters which might create confusion.

> DMA API is so abstract that it cannot cover all requirements by
> various device drivers;;

Agree.

Regards,

Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
