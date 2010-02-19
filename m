Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 39B3A6B0078
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 03:30:51 -0500 (EST)
Date: Fri, 19 Feb 2010 08:30:06 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-ID: <20100219083006.GA19649@n2100.arm.linux.org.uk>
References: <4B7C8DC2.3060004@codeaurora.org> <20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com> <4B7CF8C0.4050105@codeaurora.org> <20100218183604.95ee8c77.kamezawa.hiroyu@jp.fujitsu.com> <20100218100432.GA32626@csn.ul.ie> <4B7DEDB0.8030802@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B7DEDB0.8030802@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Michael Bohan <mbohan@codeaurora.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 18, 2010 at 05:47:28PM -0800, Michael Bohan wrote:
> I am actually using the pfn_valid implementation FLATMEM in  
> arch/arm/include/asm/memory.h.  This one is very similar to the  
> asm-generic, and has no knowledge of the holes.

Later kernels have a pfn_valid() which does have hole functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
