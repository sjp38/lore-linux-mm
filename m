Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 3A6236B00FB
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 19:18:05 -0500 (EST)
Date: Tue, 21 Feb 2012 16:18:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv22 14/16] X86: integrate CMA with DMA-mapping subsystem
Message-Id: <20120221161802.f6a28085.akpm@linux-foundation.org>
In-Reply-To: <1329507036-24362-15-git-send-email-m.szyprowski@samsung.com>
References: <1329507036-24362-1-git-send-email-m.szyprowski@samsung.com>
	<1329507036-24362-15-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

On Fri, 17 Feb 2012 20:30:34 +0100
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> This patch adds support for CMA to dma-mapping subsystem for x86
> architecture that uses common pci-dma/pci-nommu implementation. This
> allows to test CMA on KVM/QEMU and a lot of common x86 boxes.
> 
> ...
>
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -31,6 +31,7 @@ config X86
>  	select ARCH_WANT_OPTIONAL_GPIOLIB
>  	select ARCH_WANT_FRAME_POINTERS
>  	select HAVE_DMA_ATTRS
> +	select HAVE_DMA_CONTIGUOUS if !SWIOTLB
>  	select HAVE_KRETPROBES
>  	select HAVE_OPTPROBES
>  	select HAVE_FTRACE_MCOUNT_RECORD

I don't think it's compilable at all for x86_64, because that platform
selects SWIOTLB.

After a while I got it to compile for i386.  arm didn't go so well,
partly because arm allmodconfig is presently horked (something to do
with Kconfig not setting PHYS_OFFSET) and partly because arm defconfig
doesn't permit CMA to be set.  Got bored, gave up.

The patchset collides pretty seriously with pending dma api changes and
pending arm changes in linux-next, so I didn't apply anything.  This
will all need to be looked at, please.

I'll make do with reading the patches for now ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
