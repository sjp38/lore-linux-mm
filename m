Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 98FD86B0044
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 04:59:49 -0400 (EDT)
Date: Tue, 16 Oct 2012 09:59:28 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] DMA-mapping & IOMMU - physically
	contiguous allocations
Message-ID: <20121016085928.GV21164@n2100.arm.linux.org.uk>
References: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com> <CAAQKjZMYFNMEnb2ue2aR+6AEbOixnQFyggbXrThBCW5VOznePg@mail.gmail.com> <20121016090434.7d5e088152a3e0b0606903c8@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016090434.7d5e088152a3e0b0606903c8@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Inki Dae <inki.dae@samsung.com>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-tegra@vger.kernel.org

On Tue, Oct 16, 2012 at 09:04:34AM +0300, Hiroshi Doyu wrote:
> In addition to those contiguous/discontiguous page allocation, is
> there any way to _import_ anonymous pages allocated by a process to be
> used in dma-mapping API later?
> 
> I'm considering the following scenario, an user process allocates a
> buffer by malloc() in advance, and then it asks some driver to convert
> that buffer into IOMMU'able/DMA'able ones later. In this case, pages
> are discouguous and even they may not be yet allocated at
> malloc()/mmap().

That situation is covered.  It's the streaming API you're wanting for that.
dma_map_sg() - but you may need additional cache handling via
flush_dcache_page() to ensure that your code is safe for all CPU cache
architectures.

Remember that pages allocated into userspace will be cacheable, so a cache
flush is required before they can be DMA'd.  Hence the streaming API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
