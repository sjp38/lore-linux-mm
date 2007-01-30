Date: Tue, 30 Jan 2007 11:20:24 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: swap map
Message-ID: <20070130112024.GA18705@infradead.org>
References: <45BF2823.2090005@symas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45BF2823.2090005@symas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 30, 2007 at 03:12:35AM -0800, Howard Chu wrote:
> In the it-would-be-nice department... While I was twiddling with swappiness 
> and benchmarking some code, I thought it would be pretty cool if there was 
> a node in /proc/<pid> that would show which pages of a process are resident 
> or nonresident. I'm not sure that it would be useful very often, but I was 
> thinking one could get a snapshot of that, correlated with traces from a 
> malloc profiler, to show what portions of a program's memory usage was in 
> active use vs idle.

That's be a remote mincore().  This should be more or less trivial,
do_mincore would need a mm_struct argument instead of always using
current->mm and we'd need a simple seq_file interface iterating over it.

Any volunteers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
