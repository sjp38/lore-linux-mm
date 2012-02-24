Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 15B956B00E9
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 09:31:21 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv6 7/7] ARM: dma-mapping: add support for IOMMU mapper
Date: Fri, 24 Feb 2012 14:31:01 +0000
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com> <201202241249.44731.arnd@arndb.de> <013301ccf2f6$bc4ad840$34e088c0$%szyprowski@samsung.com>
In-Reply-To: <013301ccf2f6$bc4ad840$34e088c0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201202241431.02170.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Krishna Reddy' <vdumpa@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>

On Friday 24 February 2012, Marek Szyprowski wrote:
> I want to use some kind of chained arrays, each of at most of PAGE_SIZE. This code 
> doesn't really need to keep these page pointers in contiguous virtual memory area, so
> it will not be a problem here.
> 
Sounds like sg_alloc_table(), could you reuse that instead of rolling your own?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
