Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 55BDD6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 02:04:53 -0400 (EDT)
Date: Tue, 16 Oct 2012 09:04:34 +0300
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] DMA-mapping & IOMMU - physically
 contiguous allocations
Message-ID: <20121016090434.7d5e088152a3e0b0606903c8@nvidia.com>
In-Reply-To: <CAAQKjZMYFNMEnb2ue2aR+6AEbOixnQFyggbXrThBCW5VOznePg@mail.gmail.com>
References: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com>
	<CAAQKjZMYFNMEnb2ue2aR+6AEbOixnQFyggbXrThBCW5VOznePg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Inki Dae <inki.dae@samsung.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-tegra@vger.kernel.org

Hi Inki/Marek,

On Tue, 16 Oct 2012 02:50:16 +0200
Inki Dae <inki.dae@samsung.com> wrote:

> 2012/10/15 Marek Szyprowski <m.szyprowski@samsung.com>:
> > Hello,
> >
> > Some devices, which have IOMMU, for some use cases might require to
> > allocate a buffers for DMA which is contiguous in physical memory. Such
> > use cases appears for example in DRM subsystem when one wants to improve
> > performance or use secure buffer protection.
> >
> > I would like to ask if adding a new attribute, as proposed in this RFC
> > is a good idea? I feel that it might be an attribute just for a single
> > driver, but I would like to know your opinion. Should we look for other
> > solution?
> >
> 
> In addition, currently we have worked dma-mapping-based iommu support
> for exynos drm driver with this patch set so this patch set has been
> tested with iommu enabled exynos drm driver and worked fine. actually,
> this feature is needed for secure mode such as TrustZone. in case of
> Exynos SoC, memory region for secure mode should be physically
> contiguous and also maybe OMAP but now dma-mapping framework doesn't
> guarantee physically continuous memory allocation so this patch set
> would make it possible.

Agree that the contigous memory allocation is necessary for us too.

In addition to those contiguous/discontiguous page allocation, is
there any way to _import_ anonymous pages allocated by a process to be
used in dma-mapping API later?

I'm considering the following scenario, an user process allocates a
buffer by malloc() in advance, and then it asks some driver to convert
that buffer into IOMMU'able/DMA'able ones later. In this case, pages
are discouguous and even they may not be yet allocated at
malloc()/mmap().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
