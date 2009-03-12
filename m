Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B038E6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:30:22 -0400 (EDT)
Date: Thu, 12 Mar 2009 21:30:06 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] [ARM] Flush only the needed range when unmapping a VMA
Message-ID: <20090312213006.GN7854@n2100.arm.linux.org.uk>
References: <49B54B2A.9090408@nokia.com> <1236690093-3037-1-git-send-email-Aaro.Koskinen@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1236690093-3037-1-git-send-email-Aaro.Koskinen@nokia.com>
Sender: owner-linux-mm@kvack.org
To: Aaro Koskinen <Aaro.Koskinen@nokia.com>
Cc: linux-arm-kernel@lists.arm.linux.org.uk, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 10, 2009 at 03:01:33PM +0200, Aaro Koskinen wrote:
> When unmapping N pages (e.g. shared memory) the amount of TLB flushes
> done can be (N*PAGE_SIZE/ZAP_BLOCK_SIZE)*N although it should be N at
> maximum. With PREEMPT kernel ZAP_BLOCK_SIZE is 8 pages, so there is a
> noticeable performance penalty when unmapping a large VMA and the system
> is spending its time in flush_tlb_range().

It would be nice to have some figures for the speedup gained by this
optimisation - is there any chance you could provide a comparison?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
