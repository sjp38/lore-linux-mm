Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9E3906B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 11:27:57 -0400 (EDT)
Message-ID: <505B35F7.2080201@wwwdotorg.org>
Date: Thu, 20 Sep 2012 09:27:51 -0600
From: Stephen Warren <swarren@wwwdotorg.org>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] ARM: dma-mapping: New dma_map_ops to control IOVA more
 precisely
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com> <20120918124918.GK2505@amd.com> <20120919095843.d1db155e0f085f4fcf64ea32@nvidia.com> <201209190759.46174.arnd@arndb.de> <20120919125020.GQ2505@amd.com> <401E54CE964CD94BAE1EB4A729C7087E379FDC1EEB@HQMAIL04.nvidia.com> <505A7DB4.4090902@wwwdotorg.org> <401E54CE964CD94BAE1EB4A729C7087E379FDC1F2D@HQMAIL04.nvidia.com>
In-Reply-To: <401E54CE964CD94BAE1EB4A729C7087E379FDC1F2D@HQMAIL04.nvidia.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krishna Reddy <vdumpa@nvidia.com>
Cc: Joerg Roedel <joerg.roedel@amd.com>, Arnd Bergmann <arnd@arndb.de>, Hiroshi Doyu <hdoyu@nvidia.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 09/20/2012 12:40 AM, Krishna Reddy wrote:
>>> On Tegra, the following use cases need specific IOVA mapping.
>>> 1. Few MMIO blocks need IOVA=PA mapping setup.
>>
>> In that case, why would we enable the IOMMU for that one device; IOMMU
>> disabled means VA==PA, right? Perhaps isolation of the device so it can only
>> access certain PA ranges for security?
> 
> The device(H/W controller) need to access few special memory blocks(IOVA==PA)
> and DRAM as well.

OK, so only /some/ of the VA space is VA==PA, and some is remapped;
that's a little different that what you originally implied above.

BTW, which HW module is this; AVP/COP or something else. This sounds
like an odd requirement.

> There is also a case where frame buffer memory is passed from BootLoader to Kernel and
> display H/W  continues to access it with IOMMU enabled. To support this, the one to one
> mapping has to be setup before enabling IOMMU.

Yes, that makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
