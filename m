Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id CA2276B0069
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 07:10:01 -0400 (EDT)
Message-ID: <4FED8D03.10507@ladisch.de>
Date: Fri, 29 Jun 2012 13:09:55 +0200
From: Clemens Ladisch <clemens@ladisch.de>
MIME-Version: 1.0
Subject: Re: [PATCH] common: dma-mapping: add support for generic dma_mmap_*
 calls
References: <1339741135-7841-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1339741135-7841-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, David Gibson <david@gibson.dropbear.id.au>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>

Marek Szyprowski wrote:
> +++ b/drivers/base/dma-mapping.c
> ...
> +int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
> +		    void *cpu_addr, dma_addr_t dma_addr, size_t size)
> +{
> +	int ret = -ENXIO;
> +	...
> +	if (dma_mmap_from_coherent(dev, vma, cpu_addr, size, &ret))
> +		return ret;

This will return -ENXIO if dma_mmap_from_coherent() succeeds.


Regards,
Clemens

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
