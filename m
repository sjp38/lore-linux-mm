Message-ID: <445FF4B3.7020101@yahoo.com.au>
Date: Tue, 09 May 2006 11:47:31 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] Break out memory initialisation code from page_alloc.c
 to mem_init.c
References: <20060508141030.26912.93090.sendpatchset@skynet> <20060508141231.26912.52976.sendpatchset@skynet>
In-Reply-To: <20060508141231.26912.52976.sendpatchset@skynet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, davej@codemonkey.org.uk, tony.luck@intel.com, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

>page_alloc.c contains a large amount of memory initialisation code. This patch
>breaks out the initialisation code to a separate file to make page_alloc.c
>a bit easier to read.
>

I realise this is at the wrong end of your queue, but if you _can_ easily
break it out and submit it first, it would be a nice cleanup and would help
shrink your main patchset.

Also, we're recently having some problems with architectures not aligning
zones correctly. Would it make sense to add these sorts of sanity checks,
and possibly forcing alignment corrections into your generic code?

Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
