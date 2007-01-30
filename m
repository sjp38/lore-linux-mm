Message-ID: <45BF2D1E.3020207@yahoo.com.au>
Date: Tue, 30 Jan 2007 22:33:50 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: swap map
References: <45BF2823.2090005@symas.com> <20070130112024.GA18705@infradead.org>
In-Reply-To: <20070130112024.GA18705@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Howard Chu <hyc@symas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Tue, Jan 30, 2007 at 03:12:35AM -0800, Howard Chu wrote:
> 
>>In the it-would-be-nice department... While I was twiddling with swappiness 
>>and benchmarking some code, I thought it would be pretty cool if there was 
>>a node in /proc/<pid> that would show which pages of a process are resident 
>>or nonresident. I'm not sure that it would be useful very often, but I was 
>>thinking one could get a snapshot of that, correlated with traces from a 
>>malloc profiler, to show what portions of a program's memory usage was in 
>>active use vs idle.
> 
> 
> That's be a remote mincore().  This should be more or less trivial,
> do_mincore would need a mm_struct argument instead of always using
> current->mm and we'd need a simple seq_file interface iterating over it.
> 
> Any volunteers?

Well the first thing needed is an mincore that actually works for anonymous
memory!

I've implemented some fixups in that department, which should get merged
into 2.6.21. That reminds me: I'll send the patch to linux-mm for review...

We cannot get real atomic snapshots in general, but I don't think that would
be a problem if you are just doing some profiling.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
