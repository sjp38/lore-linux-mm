Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7AF2F600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 09:48:11 -0400 (EDT)
Received: from epmmp2 (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L670044KYC9OW40@mailout2.samsung.com> for linux-mm@kvack.org;
 Tue, 27 Jul 2010 22:48:09 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp2.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0L670011XYBULS@mmp2.samsung.com> for linux-mm@kvack.org; Tue,
 27 Jul 2010 22:48:09 +0900 (KST)
Date: Tue, 27 Jul 2010 15:46:26 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv2 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100727065842.40ae76c8@bike.lwn.net>
Message-id: <003f01cb2d92$20819730$6184c590$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <cover.1280151963.git.m.nazarewicz@samsung.com>
 <743102607e2c5fb20e3c0676fadbcb93d501a78e.1280151963.git.m.nazarewicz@samsung.com>
 <dc4bdf3e0b02c0ac4770927f72b6cbc3f0b486a2.1280151963.git.m.nazarewicz@samsung.com>
 <20100727120841.GC11468@n2100.arm.linux.org.uk>
 <003701cb2d89$adae4580$090ad080$%szyprowski@samsung.com>
 <20100727065842.40ae76c8@bike.lwn.net>
Sender: owner-linux-mm@kvack.org
To: 'Jonathan Corbet' <corbet@lwn.net>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, 'Daniel Walker' <dwalker@codeaurora.org>, Pawel Osciak <p.osciak@samsung.com>, 'Mark Brown' <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Zach Pfeffer' <zpfeffer@codeaurora.org>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tuesday, July 27, 2010 2:59 PM Jonathan Corbet wrote:

> On Tue, 27 Jul 2010 14:45:58 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> 
> > > How does one obtain the CPU address of this memory in order for the CPU
> > > to access it?
> >
> > Right, we did not cover such case. In CMA approach we tried to separate
> > memory allocation from the memory mapping into user/kernel space. Mapping
> > a buffer is much more complicated process that cannot be handled in a
> > generic way, so we decided to leave this for the device drivers. Usually
> > video processing devices also don't need in-kernel mapping for such
> > buffers at all.
> 
> Still...that *is* why I suggested an interface which would return both
> the DMA address and a kernel-space virtual address, just like the DMA
> API does...  Either that, or just return the void * kernel address and
> let drivers do the DMA mapping themselves.  Returning only the
> dma_addr_t address will make the interface difficult to use in many
> situations.

As I said, drivers usually don't need in-kernel mapping for video buffers.
Is there really a need for creating such mapping?

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
