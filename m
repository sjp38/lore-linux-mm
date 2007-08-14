Received: from [128.115.172.161] (smeagol.llnl.gov [128.115.172.161])
	(authenticated bits=0)
	by mail-1.llnl.gov (8.13.1/8.12.3/LLNL evision: 1.6 $) with ESMTP id l7EIGqZu002382
	for <linux-mm@kvack.org>; Tue, 14 Aug 2007 11:16:52 -0700
Message-ID: <46C1F194.8080405@llnl.gov>
Date: Tue, 14 Aug 2007 11:16:52 -0700
From: Jeff Keasler <keasler@llnl.gov>
Reply-To: keasler@llnl.gov
MIME-Version: 1.0
Subject: L2 cache alignment and page coloring
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I work in an HPC environment where we run a process with a tight inner 
loop (entirely contained in the I-cache) to work on large quantities of 
data.  We've reduced system services to minimize our process getting 
swapped out.

I am concerned that using malloc(L2_CACHE_SIZE) in user space is mapping 
the underlying physical pages such that they do not form a cover of the 
L2 cache (i.e. several physical pages are aliasing into the same part of 
the L2 cache).

Are there any tricks available to force a more cache friendly 
virtual-to-physical mapping from user space?

Thanks,
-Jeff

PS  Even better if it is likely to work for L3 cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
