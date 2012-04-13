Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C74B36B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 14:38:35 -0400 (EDT)
Date: Fri, 13 Apr 2012 19:38:13 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 4/4] ARM: remove consistent dma region and use common
	vmalloc range for dma allocations
Message-ID: <20120413183813.GO24211@n2100.arm.linux.org.uk>
References: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com> <1334325950-7881-5-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334325950-7881-5-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

On Fri, Apr 13, 2012 at 04:05:50PM +0200, Marek Szyprowski wrote:
> This patch changes dma-mapping subsystem to use generic vmalloc areas
> for all consistent dma allocations. This increases the total size limit
> of the consistent allocations and removes platform hacks and a lot of
> duplicated code.

NAK.  I don't think you appreciate the contexts from which the dma coherent
code can be called from, and the reason why we pre-allocate the page
tables (so that IRQ-based allocations work.)

The vmalloc region doesn't allow that because page tables are allocated
using GFP_KERNEL not GFP_ATOMIC.

Sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
