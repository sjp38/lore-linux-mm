Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D0E6B6B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 03:08:18 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=utf-8
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L60006ZO15MQ440@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Jul 2010 08:08:10 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L6000EEH15L4Q@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Jul 2010 08:08:10 +0100 (BST)
Date: Fri, 23 Jul 2010 09:06:42 +0200
From: Pawel Osciak <p.osciak@samsung.com>
Subject: RE: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100722045435.GD22559@codeaurora.org>
Message-id: <001101cb2a35$9ae05ee0$d0a11ca0$%osciak@samsung.com>
Content-language: pl
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <20100722045435.GD22559@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: 'Zach Pfeffer' <zpfeffer@codeaurora.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

Hi Zach,

>Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
>On Tue, Jul 20, 2010 at 05:51:25PM +0200, Michal Nazarewicz wrote:

(snip)

>> +* Contiguous Memory Allocator
>> +
>> +   The Contiguous Memory Allocator (CMA) is a framework, which allows
>> +   setting up a machine-specific configuration for physically-contiguous
>> +   memory management. Memory for devices is then allocated according
>> +   to that configuration.
>> +
>> +   The main role of the framework is not to allocate memory, but to
>> +   parse and manage memory configurations, as well as to act as an
>> +   in-between between device drivers and pluggable allocators. It is
>> +   thus not tied to any memory allocation method or strategy.
>> +
>
>This topic seems very hot lately. I recently sent out a few RFCs that
>implement something called a Virtual Contiguous Memory Manager that
>does what this patch does, and works for IOMMU and works for CPU
>mappings. It also does multihomed memory targeting (use physical set 1
>memory for A allocations and use physical memory set 2 for B
>allocations). Check out:
>
>mm: iommu: An API to unify IOMMU, CPU and device memory management
>mm: iommu: A physical allocator for the VCMM
>mm: iommu: The Virtual Contiguous Memory Manager
>
>It unifies IOMMU and physical mappings by creating a one-to-one
>software IOMMU for all devices that map memory physically.
>
>It looks like you've got some good ideas though. Perhaps we can
>leverage each other's work.

Yes, I have read your RFCs when they originally come out and I think
that CMA could be used as a physical memory allocator for VCMM, if such
a need arises. Of course this would only make sense in special cases.
One idea I have is that this could be useful if we wanted to have
a common kernel for devices with and without an IOMMU. This way the
same virtual address spaces could be set up on top of different
allocators for different systems and use discontiguous memory for
SoCs with an IOMMU and contiguous for SoCs without it. What do you
think?

I am aware that you have your own physical memory allocator, but from
what you wrote, you use pools of contiguous memory consisting of
indivisible, fixed-size blocks (which is of course a good idea in the
presence of an IOMMU). Moreover, those advanced region traits and
sharing specification features of CMA are a must for us.

I don't perceive VCMM and CMA as competing solutions for the same
problem, they solve different problems and I believe could not only
coexist, but be used together in specific use cases.


Best regards
--
Pawel Osciak
Linux Platform Group
Samsung Poland R&D Center





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
