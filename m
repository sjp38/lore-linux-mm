Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB7F6B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 17:13:30 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o1BMDQDm021113
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 22:13:26 GMT
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by spaceape11.eur.corp.google.com with ESMTP id o1BMDIuW013755
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 14:13:25 -0800
Received: by pxi13 with SMTP id 13so1217928pxi.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 14:13:22 -0800 (PST)
Date: Thu, 11 Feb 2010 14:13:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: suppress pfn range output for zones without pages
In-Reply-To: <alpine.DEB.2.00.1002111406110.7201@router.home>
Message-ID: <alpine.DEB.2.00.1002111405120.16763@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com> <alpine.DEB.2.00.1002111406110.7201@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Christoph Lameter wrote:

> > The output is now suppressed for zones that do not have a valid pfn
> > range.
> 
> There is a difference between zone support not compiled into the kernel
> and the zone being empty. The output so far allows me to see that support
> for a zone was compiled into the kernel but it is empty.
> 

So you want to parse this table of zone pfn ranges to determine, for 
example, whether CONFIG_HIGHMEM was enabled for i386 kernels?  That 
doesn't tell you whether its CONFIG_HIGHMEM4G or CONFIG_HIGHMEM64G, so 
it's a pretty bad way to interpret the kernel config and decide whether 
the pfn ranges are valid or not.  The only other use case would be to find 
if the values are sane when we don't have CONFIG_ZONE_DMA or 
CONFIG_ZONE_DMA32, but those typically aren't even disabled: I just sent a 
patch to the x86 maintainers to get that configuration to compile on -rc7.  

In other words, I don't think we need to be emitting kernel diagnostic 
messages for zones that are empty and unused just because they are enabled 
in the kernel config; no developer is going to care about parsing the 
usecase I showed in the changelog since ZONE_NORMAL is always defined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
