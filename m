Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 951836B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 04:51:56 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L6900E0OFACOJ@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 28 Jul 2010 09:51:48 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L6900B7BFABFQ@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 28 Jul 2010 09:51:48 +0100 (BST)
Date: Wed, 28 Jul 2010 10:53:17 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCHv2 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100727120841.GC11468@n2100.arm.linux.org.uk>
Message-id: <op.vgjpm3it7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1280151963.git.m.nazarewicz@samsung.com>
 <743102607e2c5fb20e3c0676fadbcb93d501a78e.1280151963.git.m.nazarewicz@samsung.com>
 <dc4bdf3e0b02c0ac4770927f72b6cbc3f0b486a2.1280151963.git.m.nazarewicz@samsung.com>
 <20100727120841.GC11468@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, Hiremath Vaibhav <hvaibhav@ti.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> +static inline dma_addr_t __must_check
>> +cma_alloc(const struct device *dev, const char *kind,
>> +	  size_t size, dma_addr_t alignment)
>> +{
>> +	return dev ? -EINVAL : __cma_alloc(dev, kind, size, alignment);

On Tue, 27 Jul 2010 14:08:41 +0200, Russell King - ARM Linux <linux@arm.=
linux.org.uk> wrote:
> So I can't use this to allocate memory for anything but a NULL device?=


>> +static inline int
>> +cma_info(struct cma_info *info, const struct device *dev, const char=
 *kind)
>> +{
>> +	return dev ? -EINVAL : __cma_info(info, dev, kind);

> This won't return information for anything but a NULL device?

Obviously a bug.  Thanks for spotting that.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
