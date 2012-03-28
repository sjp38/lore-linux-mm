Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 62D5B6B00E7
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 07:30:42 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so1060411bkw.14
        for <linux-mm@kvack.org>; Wed, 28 Mar 2012 04:30:40 -0700 (PDT)
Message-ID: <4F72F603.2000803@mvista.com>
Date: Wed, 28 Mar 2012 15:29:07 +0400
From: Sergei Shtylyov <sshtylyov@mvista.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 01/14] common: dma-mapping: introduce alloc_attrs and
 free_attrs methods
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com> <1332855768-32583-2-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1332855768-32583-2-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Hello.

On 27-03-2012 17:42, Marek Szyprowski wrote:

> Introduce new generic alloc and free methods with attributes argument.

    The method names don't match the ones in the subject.

> Existing alloc_coherent and free_coherent can be implemented on top of the
> new calls with NULL attributes argument. Later also dma_alloc_non_coherent
> can be implemented using DMA_ATTR_NONCOHERENT attribute as well as
> dma_alloc_writecombine with separate DMA_ATTR_WRITECOMBINE attribute.

> This way the drivers will get more generic, platform independent way of
> allocating dma buffers with specific parameters.

> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> Reviewed-by: David Gibson <david@gibson.dropbear.ud.au>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

WBR, Sergei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
