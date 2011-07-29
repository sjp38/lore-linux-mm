Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CD9376B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 06:54:24 -0400 (EDT)
Date: Fri, 29 Jul 2011 12:54:22 +0200
From: 'Joerg Roedel' <joro@8bytes.org>
Subject: Re: [RFC] ARM: dma_map|unmap_sg plus iommu
Message-ID: <20110729105422.GB13522@8bytes.org>
References: <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com> <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com> <20110729093555.GA13522@8bytes.org> <001901cc4dd8$4afb4e40$e0f1eac0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001901cc4dd8$4afb4e40$e0f1eac0$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "'Ramirez Luna, Omar'" <omar.ramirez@ti.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Ohad Ben-Cohen' <ohad@wizery.com>

On Fri, Jul 29, 2011 at 12:14:25PM +0200, Marek Szyprowski wrote:
> > This sounds rather hacky. How about partitioning the address space for
> > the device and give the dma-api only a part of it. The other parts can
> > be directly mapped using the iommu-api then.
> 
> Well, I'm not convinced that iommu-api should be used by the device drivers 
> directly. If possible we should rather extend dma-mapping than use such hacks.

Building this into dma-api would turn it into an iommu-api. The line
between the apis are clear. The iommu-api provides direct mapping
of bus-addresses to system-addresses while the dma-api puts a memory
manager on-top which deals with bus-address allocation itself.
So if you want to map bus-addresses directly the iommu-api is the way to
go. This is in no way a hack.

Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
