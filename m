Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 989C36B005D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 06:03:13 -0500 (EST)
Message-ID: <50A0D764.204@web.de>
Date: Mon, 12 Nov 2012 12:03:00 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <1352356737-14413-1-git-send-email-m.szyprowski@samsung.com> <20121111172243.GB821@lunn.ch> <50A0C5D2.7000806@web.de> <20121112103820.GX22029@lunn.ch>
In-Reply-To: <20121112103820.GX22029@lunn.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lunn <andrew@lunn.ch>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 12.11.2012 11:38, Andrew Lunn wrote:
> On Mon, Nov 12, 2012 at 10:48:02AM +0100, Soeren Moch wrote:
>> On 11.11.2012 18:22, Andrew Lunn wrote:
>>> On Thu, Nov 08, 2012 at 07:38:57AM +0100, Marek Szyprowski wrote:
>>>> dmapool always calls dma_alloc_coherent() with GFP_ATOMIC flag,
>> regardless
>>>> the flags provided by the caller. This causes excessive pruning of
>>>> emergency memory pools without any good reason. This patch
>> changes the code
>>>> to correctly use gfp flags provided by the dmapool caller. This should
>>>> solve the dmapool usage on ARM architecture, where GFP_ATOMIC DMA
>>>> allocations can be served only from the special, very limited
>> memory pool.
>>>> Reported-by: Soren Moch <smoch@web.de>
>> Please use
>> Reported-by: Soeren Moch <smoch@web.de>
>>
>>>> Reported-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>>>> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
>>> Tested-by: Andrew Lunn <andrew@lunn.ch>
>>>
>>> I tested this on a Kirkwood QNAP after removing the call to
>>> init_dma_coherent_pool_size().
>>>
>>>      Andrew
>> Tested-by: Soeren Moch <smoch@web.de>
>>
>> Now I had a chance to test this patch on my Kirkwood guruplug
>> system with linux-3.6.6 . It is running much better now, but with the
>> original 256K coherent pool size I still see errors after several hours
>> of runtime:
>>
>> Nov 12 09:42:32 guru kernel: ERROR: 256 KiB atomic DMA coherent pool
>> is too small!
>> Nov 12 09:42:32 guru kernel: Please increase it with coherent_pool=
>> kernel parameter!
> Hi Soeren
>
> Could you tell us what DVB devices you are using.
>
> Thanks
> 	Andrew

from lsusb:
Bus 001 Device 005: ID 0ccd:00b2 TerraTec Electronic GmbH
Bus 001 Device 006: ID 2040:5200 Hauppauge
Bus 001 Device 009: ID 2304:0242 Pinnacle Systems, Inc.

If you want to check the drivers, I recommend to start with "em28xx".

Regards,
Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
