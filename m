Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A4FA390023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 12:23:19 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 7/8] common: dma-mapping: change alloc/free_coherent method to more generic alloc/free_attrs
Date: Fri, 24 Jun 2011 18:23:01 +0200
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <201106241751.35655.arnd@arndb.de> <1308932147.5929.0.camel@mulgrave>
In-Reply-To: <1308932147.5929.0.camel@mulgrave>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201106241823.01273.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

On Friday 24 June 2011, James Bottomley wrote:
> On Fri, 2011-06-24 at 17:51 +0200, Arnd Bergmann wrote:
> > Yes, I think that is good, but the change needs to be done atomically
> > across all architectures. This should be easy enough as I believe
> > all other architectures that use dma_map_ops don't even require
> > dma_alloc_noncoherent
> 
> This statement is definitely not true of parisc, and also, I believe,
> not true of sh, so that would have to figure in the conversion work too.

As far as I can tell, parisc uses its own hppa_dma_ops, not
dma_map_ops, and arch/sh/include/asm/dma-mapping.h contains an
unconditional

#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)

If you want to change parisc to use dma_map_ops then I would suggest
adding another attribute for alloc_noncoherent.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
