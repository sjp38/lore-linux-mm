Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AE7FB90023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:47:23 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 5/8] ARM: dma-mapping: move all dma bounce code to separate dma ops structure
Date: Fri, 24 Jun 2011 17:47:02 +0200
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <20110620144247.GF26089@n2100.arm.linux.org.uk> <000901cc2f5f$237795a0$6a66c0e0$%szyprowski@samsung.com>
In-Reply-To: <000901cc2f5f$237795a0$6a66c0e0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106241747.03113.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>

On Monday 20 June 2011, Marek Szyprowski wrote:
> On Monday, June 20, 2011 4:43 PM Russell King - ARM Linux wrote:
> 
> > On Mon, Jun 20, 2011 at 09:50:10AM +0200, Marek Szyprowski wrote:
> > > This patch removes dma bounce hooks from the common dma mapping
> > > implementation on ARM architecture and creates a separate set of
> > > dma_map_ops for dma bounce devices.
> > 
> > Why all this additional indirection for no gain?
> 
> I've did it to really separate dmabounce code and let it be completely 
> independent of particular internal functions of the main generic dma-mapping
> code.
> 
> dmabounce is just one of possible dma-mapping implementation and it is really
> convenient to have it closed into common interface (dma_map_ops) rather than
> having it spread around and hardcoded behind some #ifdefs in generic ARM
> dma-mapping.
> 
> There will be also other dma-mapping implementations in the future - I 
> thinking mainly of some iommu capable versions. 
> 
> In terms of speed I really doubt that these changes have any impact on the
> system performance, but they significantly improves the code readability 
> (see next patch with cleanup of dma-mapping.c).

Yes. I believe the main effect of splitting out dmabounce into its own
set of operations is improved readability for people that are not
familiar with the existing code (which excludes Russell ;-) ), by
separating the two codepaths and losing various #ifdef.

The simplification becomes more obvious when you look at patch 6, which
removes a lot of the code that becomes redundant after this one.

Still, patches 5 and 6 are certainly not essential, nothing depends on
that and if Russell still doesn't like them, they can easily be dropped.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
