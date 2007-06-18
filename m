Message-Id: <20070618191956.411091458@sgi.com>
Date: Mon, 18 Jun 2007 12:19:56 -0700
From: clameter@sgi.com
Subject: [patch 00/10] NUMA: Memoryless Node support V1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is addressing various issues with NUMA as a result of memory
less nodes being used. I think this is only a start fixing the most obvious
things, there may be more where this came from. I'd appreciate if someone
with a system with memoryless nodes could do systematic testing to see that
all the NUMA functionality works properly. Nishanth has done some testing
but he seems to be farily new to this.

The patchset is also part of my upload queue at
http://ftp.kernel.org/pub/linux/kernel/people/christoph/2.6.22-rc4-mm2

I know that some people are doing work based on this patchset. Will update
the patches in that location if more fixes are submitted. I hope Andrew
will get a new mm version out soon.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
