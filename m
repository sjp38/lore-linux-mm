Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 149F490023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:20:31 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping
 =?iso-8859-1?q?framework=09redesign?=
Date: Fri, 24 Jun 2011 17:20:15 +0200
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <002701cc30be$ab296cc0$017c4640$%szyprowski@samsung.com> <4E02119F.4000901@codeaurora.org>
In-Reply-To: <4E02119F.4000901@codeaurora.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106241720.15385.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jordan Crouse <jcrouse@codeaurora.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Subash Patel' <subashrp@gmail.com>, linux-arch@vger.kernel.org, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Joerg Roedel' <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

On Wednesday 22 June 2011, Jordan Crouse wrote:
> >> I have a query in similar lines, but related to user virtual address
> >> space. Is it feasible to extend these DMA interfaces(and IOMMU), to map
> >> a user allocated buffer into the hardware?
> >
> > This can be done with the current API, although it may not look so
> > straightforward. You just need to create a scatter list of user pages
> > (these can be gathered with get_user_pages function) and use dma_map_sg()
> > function. If the dma-mapping support iommu, it can map all these pages
> > into a single contiguous buffer on device (DMA) address space.
> >
> > Some additional 'magic' might be required to get access to pages that are
> > mapped with pure PFN (VM_PFNMAP flag), but imho it still can be done.
> >
> > I will try to implement this feature in videobuf2-dma-config allocator
> > together with the next version of my patches for dma-mapping&iommu.
> 
> With luck DMA_ATTRIB_NO_KERNEL_MAPPING should remove any lingering arguments
> for trying to map user pages. Given that our ultimate goal here is buffer
> sharing, user allocated pages have limited value and appeal. If anything, I
> vote that this be a far lower priority compared to the rest of the win you
> have here.

I agree. Mapping user-allocated buffers is extremely hard to get right
when there are extra constraints. If it doesn't work already for some driver,
I wouldn't put too much effort into making it work for more special cases.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
