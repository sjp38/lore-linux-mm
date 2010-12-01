Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9C06F6B0089
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 03:24:29 -0500 (EST)
Subject: Re: [PATCH 1/3] mm: kswapd: Stop high-order balancing when any
 suitable zone is balanced
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20101201164647.ABD7.A69D9226@jp.fujitsu.com>
References: <20101201122638.ABBF.A69D9226@jp.fujitsu.com>
	 <1291189227.12777.79.camel@sli10-conroe>
	 <20101201164647.ABD7.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 16:24:26 +0800
Message-ID: <1291191866.12777.82.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Simon Kirby <sim@hostway.ca>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-12-01 at 15:52 +0800, KOSAKI Motohiro wrote:
> > > > > we can't make
> > > > > perfect VM heuristics obviously, then we need to compare pros/cons.
> > > > if you don't care about small system, let's consider a NORMAL i386
> > > > system with 896m normal zone, and 896M*3 high zone. normal zone will
> > > > quickly exhaust by high order high zone allocation, leave a latter
> > > > allocation which does need normal zone fail.
> > > 
> > > Not happen. slab don't allocate from highmem and page cache allocation
> > > is always using order-0. When happen high order high zone allocation?
> > ok, thanks, I missed this. then how about a x86_64 box with 896M DMA32
> > and 896*3M NORMAL? some pci devices can only dma to DMA32 zone.
> 
> First, DMA32 is 4GB. Second, modern high end system don't use 32bit PCI
> device. Third, while we are thinking desktop users, 4GB is not small
> room. nowadays, typical desktop have only 2GB or 4GB memory.
DMA32 isn't 4G, because there is hole under 4G for PCI bars. I don't
think 32 bit PCI device is rare too. But anyway, if you insist this
isn't a big issue, I'm ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
