Message-ID: <4603BC6C.4010902@yahoo.com.au>
Date: Fri, 23 Mar 2007 22:39:24 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>	<20070322223927.bb4caf43.akpm@linux-foundation.org>	<Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com> <20070322234848.100abb3d.akpm@linux-foundation.org>
In-Reply-To: <20070322234848.100abb3d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> but it crashes early in the page allocator (i386) and I don't see why.  It
> makes me wonder if we have a use-after-free which is hidden by the presence
> of the quicklist buffering or something.

Does CONFIG_DEBUG_PAGEALLOC catch it?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
