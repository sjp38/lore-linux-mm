Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 8B71C6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 08:42:33 -0400 (EDT)
Received: from eusync2.samsung.com (mailout4.w1.samsung.com [210.118.77.14])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M8C000MX3BXHX50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Aug 2012 13:43:10 +0100 (BST)
Received: from [106.116.147.108] by eusync2.samsung.com
 (Oracle Communications Messaging Server 7u4-23.01(7.0.4.23.0) 64bit (built Aug
 10 2011)) with ESMTPA id <0M8C0011W3AUKP40@eusync2.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Aug 2012 13:42:31 +0100 (BST)
Message-id: <501FBBB4.6000109@samsung.com>
Date: Mon, 06 Aug 2012 14:42:28 +0200
From: Tomasz Stanislawski <t.stanislaws@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 2/2] dma-buf: add helpers for attacher dma-parms
References: <1342715014-5316-1-git-send-email-rob.clark@linaro.org>
 <1342715014-5316-3-git-send-email-rob.clark@linaro.org>
 <501F9C8E.4080002@samsung.com> <xa1tobmoxmdz.fsf@mina86.com>
In-reply-to: <xa1tobmoxmdz.fsf@mina86.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Rob Clark <rob.clark@linaro.org>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, patches@linaro.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, daniel@ffwll.ch, sumit.semwal@ti.com, maarten.lankhorst@canonical.com, Rob Clark <rob@ti.com>

On 08/06/2012 01:58 PM, Michal Nazarewicz wrote:
> 
> Tomasz Stanislawski <t.stanislaws@samsung.com> writes:
>> I recommend to change the semantics for unlimited number of segments
>> from 'value 0' to:
>>
>> #define DMA_SEGMENTS_COUNT_UNLIMITED ((unsigned long)INT_MAX)

Sorry. It should be:
#define DMA_SEGMENTS_COUNT_UNLIMITED ((unsigned int)INT_MAX)

>>
>> Using INT_MAX will allow using safe conversions between signed and
>> unsigned integers.
> 
> LONG_MAX seems cleaner regardless.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
