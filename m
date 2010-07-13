Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 182686201FE
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 08:07:04 -0400 (EDT)
Date: Tue, 13 Jul 2010 05:06:55 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100713120654.GA4263@codeaurora.org>
References: <4C2D965F.5000206@codeaurora.org>
 <20100710145639.GC10080@8bytes.org>
 <4C3BFDD3.8040209@codeaurora.org>
 <20100713145852C.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100713145852C.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: joro@8bytes.org, dwalker@codeaurora.org, andi@firstfloor.org, randy.dunlap@oracle.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 02:59:08PM +0900, FUJITA Tomonori wrote:
> On Mon, 12 Jul 2010 22:46:59 -0700
> Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> 
> > Joerg Roedel wrote:
> > > On Fri, Jul 02, 2010 at 12:33:51AM -0700, Zach Pfeffer wrote:
> > >> Daniel Walker wrote:
> > > 
> > >>> So if we include this code which "map implementations" could you
> > >>> collapse into this implementations ? Generally , what currently existing
> > >>> code can VCMM help to eliminate?
> > >> In theory, it can eliminate all code the interoperates between IOMMU,
> > >> CPU and non-IOMMU based devices and all the mapping code, alignment,
> > >> mapping attribute and special block size support that's been
> > >> implemented.
> > > 
> > > Thats a very abstract statement. Can you point to particular code files
> > > and give a rough sketch how it could be improved using VCMM?
> > 
> > I can. Not to single out a particular subsystem, but the video4linux
> > code contains interoperation code to abstract the difference between
> > sg buffers, vmalloc buffers and physically contiguous buffers. The
> > VCMM is an attempt to provide a framework where these and all the
> > other buffer types can be unified.
> 
> Why video4linux can't use the DMA API? Doing DMA with vmalloc'ed
> buffers is a thing that we should avoid (there are some exceptions
> like xfs though).

I'm not sure, but I know that it makes the distinction. From
video4linux/videobuf:

    <media/videobuf-dma-sg.h>           /* Physically scattered */              
    <media/videobuf-vmalloc.h>          /* vmalloc() buffers    */              
    <media/videobuf-dma-contig.h>       /* Physically contiguous */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
