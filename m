Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 773606B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 14:02:00 -0400 (EDT)
Date: Mon, 13 Jun 2011 19:01:49 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
Message-ID: <20110613180149.GG13499@e102109-lin.cambridge.arm.com>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
 <BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
 <201106131707.49217.arnd@arndb.de>
 <BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
 <20110613154033.GA29185@1n450.cable.virginmedia.net>
 <BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Jun 13, 2011 at 05:00:16PM +0100, KyongHo Cho wrote:
> > FWIW, on ARMv6 and later hardware, the dma_alloc_coherent() provides
> > writecombine memory (i.e. Normal Noncacheable), so no need for
> > dma_alloc_writecombine(). On earlier architectures it is creating
> > Strongly Ordered mappings (no writecombine).
>
> Do you mean that dma_alloc_coherent() and dma_alloc_writecombine() are
> not different
> except some additional features of dma_alloc_coherent() in ARM?
=20
When CONFIG_DMA_MEM_BUFFERABLE is enabled (by default on ARMv7 and ARMv6
with some exceptions because of hardware issues), the resulting mapping
for both coherent and writecombine is the same. In both cases the
mapping is done as L_PTE_MT_BUFFERABLE which is what you want with
writecombine. You can check the pgprot_writecombine() and
pgprot_dmacoherent() macros in asm/pgtable.h

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
