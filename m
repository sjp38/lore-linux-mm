Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E877D6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 03:51:04 -0400 (EDT)
Date: Mon, 18 Jun 2012 10:50:59 +0300
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: Re: [PATCH/RFC 0/2] ARM: DMA-mapping: new extensions for buffer
 sharing (part 2)
Message-ID: <20120618105059.12c709d68240ad18c5f8c7a5@nvidia.com>
In-Reply-To: <1338988657-20770-1-git-send-email-m.szyprowski@samsung.com>
References: <1338988657-20770-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King -
 ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit
 Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hi Marek,

On Wed, 6 Jun 2012 15:17:35 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> Hello,
> 
> This is a continuation of the dma-mapping extensions posted in the
> following thread:
> http://thread.gmane.org/gmane.linux.kernel.mm/78644
> 
> We noticed that some advanced buffer sharing use cases usually require
> creating a dma mapping for the same memory buffer for more than one
> device. Usually also such buffer is never touched with CPU, so the data
> are processed by the devices.
> 
> From the DMA-mapping perspective this requires to call one of the
> dma_map_{page,single,sg} function for the given memory buffer a few
> times, for each of the devices. Each dma_map_* call performs CPU cache
> synchronization, what might be a time consuming operation, especially
> when the buffers are large. We would like to avoid any useless and time
> consuming operations, so that was the main reason for introducing
> another attribute for DMA-mapping subsystem: DMA_ATTR_SKIP_CPU_SYNC,
> which lets dma-mapping core to skip CPU cache synchronization in certain
> cases.

I had implemented the similer patch(*1) to optimize/skip the cache
maintanace, but we did this with "dir", not with "attr", making use of
the existing DMA_NONE to skip cache operations. I'm just interested in
why you choose attr for this purpose. Could you enlight me why attr is
used here?

Any way, this feature is necessary for us. Thank you for posting them.

*1: FYI:
