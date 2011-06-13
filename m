Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3716E6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:40:19 -0400 (EDT)
Received: by wyf19 with SMTP id 19so4365704wyf.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 08:40:15 -0700 (PDT)
Date: Mon, 13 Jun 2011 16:40:33 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC 0/2] ARM: DMA-mapping & IOMMU integration
Message-ID: <20110613154033.GA29185@1n450.cable.virginmedia.net>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
 <BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
 <201106131707.49217.arnd@arndb.de>
 <BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Jun 14, 2011 at 12:30:44AM +0900, KyongHo Cho wrote:
> On Tue, Jun 14, 2011 at 12:07 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > I'm sure that the graphics people will disagree with you on that.
> > Having the frame buffer mapped in write-combine mode is rather
> > important when you want to efficiently output videos from your
> > CPU.
>
> I agree with you.
> But I am discussing about dma_alloc_writecombine() in ARM.
> You can see that only ARM and AVR32 implement it and there are few
> drivers which use it.
> No function in dma_map_ops corresponds to dma_alloc_writecombine().
> That's why Marek tried to add 'alloc_writecombine' to dma_map_ops.

FWIW, on ARMv6 and later hardware, the dma_alloc_coherent() provides
writecombine memory (i.e. Normal Noncacheable), so no need for
dma_alloc_writecombine(). On earlier architectures it is creating
Strongly Ordered mappings (no writecombine).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
