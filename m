Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B45326B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:52:18 -0400 (EDT)
Date: Thu, 29 Mar 2012 15:51:36 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv2 02/14] X86 & IA64: adapt for dma_map_ops changes
In-Reply-To: <1332855768-32583-3-git-send-email-m.szyprowski@samsung.com>
Message-ID: <alpine.LFD.2.02.1203291545520.2542@ionos>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com> <1332855768-32583-3-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Tue, 27 Mar 2012, Marek Szyprowski wrote:
> From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> -static inline void *dma_alloc_coherent(struct device *dev, size_t size,
> -				       dma_addr_t *daddr, gfp_t gfp)
> +#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)

Please make this an inline function.

>  
> +#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)

Inline please.

> -static inline void dma_free_coherent(struct device *dev, size_t size,
> -				     void *vaddr, dma_addr_t bus)
> +#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)

Ditto

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
