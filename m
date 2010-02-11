Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A8CF062000E
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 17:33:25 -0500 (EST)
Date: Thu, 11 Feb 2010 16:32:51 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] mm: suppress pfn range output for zones without pages
In-Reply-To: <alpine.DEB.2.00.1002111405120.16763@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002111626440.7201@router.home>
References: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com> <alpine.DEB.2.00.1002111406110.7201@router.home> <alpine.DEB.2.00.1002111405120.16763@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, David Rientjes wrote:

> So you want to parse this table of zone pfn ranges to determine, for
> example, whether CONFIG_HIGHMEM was enabled for i386 kernels?  That
> doesn't tell you whether its CONFIG_HIGHMEM4G or CONFIG_HIGHMEM64G, so
> it's a pretty bad way to interpret the kernel config and decide whether

It tells me that there is highmem zone.

> the pfn ranges are valid or not.  The only other use case would be to find
> if the values are sane when we don't have CONFIG_ZONE_DMA or
> CONFIG_ZONE_DMA32, but those typically aren't even disabled: I just sent a
> patch to the x86 maintainers to get that configuration to compile on -rc7.

CONFIG_ZONE_DMA32 is disabled on 32 bit
CONFIG_ZONE_DMA may be disabled on IA64 or other platforms that do have
priviledged areas of memory.

Strange embedded kernel configs may sometimes play tricks with ZONE_DMA.

> In other words, I don't think we need to be emitting kernel diagnostic
> messages for zones that are empty and unused just because they are enabled
> in the kernel config; no developer is going to care about parsing the
> usecase I showed in the changelog since ZONE_NORMAL is always defined.

The kernel zone based arrays will still be dimensioned based on the
configured zones even if you omit those from the display. This influences
memory allocation.

I do not feel strongly about this since I can always look at the .config
files but you are removing information from the kernel log that I have
been using in the past.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
