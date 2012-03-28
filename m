Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7F1276B0044
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 23:57:48 -0400 (EDT)
Message-ID: <1332907000.2882.74.camel@pasglop>
Subject: Re: [PATCHv2 04/14] PowerPC: adapt for dma_map_ops changes
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 28 Mar 2012 14:56:40 +1100
In-Reply-To: <1332855768-32583-5-git-send-email-m.szyprowski@samsung.com>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
	 <1332855768-32583-5-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, Kevin Cernekee <cernekee@gmail.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Jonathan Corbet <corbet@lwn.net>, x86@kernel.org, Matt Turner <mattst88@gmail.com>, Dezhong Diao <dediao@cisco.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, microblaze-uclinux@itee.uq.edu.au, linaro-mm-sig@lists.linaro.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Richard Henderson <rth@twiddle.net>, discuss@x86-64.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Richard Kuo <rkuo@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Kyungmin Park <kyungmin.park@samsung.com>, Paul Mundt <lethal@linux-sh.org>, linux-alpha@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David
 S. Miller" <davem@davemloft.net>

On Tue, 2012-03-27 at 15:42 +0200, Marek Szyprowski wrote:
> From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> 
> Adapt core PowerPC architecture code for dma_map_ops changes: replace
> alloc/free_coherent with generic alloc/free methods.
> 
> Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> [added missing changes to arch/powerpc/kernel/vio.c]
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: David Gibson <david@gibson.dropbear.id.au>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
> ---

FYI. David and Arnd reviews are good enough for me ppc-side.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
