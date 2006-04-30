Message-ID: <44549D96.2050004@yahoo.com.au>
Date: Sun, 30 Apr 2006 21:20:54 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless page cache test results
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org> <Pine.LNX.4.64.0604261130450.19587@schroedinger.engr.sgi.com> <20060426114737.239806a2.akpm@osdl.org> <20060426184945.GL5002@suse.de> <Pine.LNX.4.64.0604261330310.20897@schroedinger.engr.sgi.com> <20060428140146.GA4657648@melbourne.sgi.com> <44548834.5050204@yahoo.com.au>
In-Reply-To: <44548834.5050204@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> As well as lockless pagecache, I think we can batch tree_lock operations
> in readahead. Would be interesting to see how much this patch helps.

Btw. the patch introduces multiple locked pages in pagecache from a single
thread, however there should be no new deadlocks or lock orderings
introduced. They are always aquired because they are new pages, so will all
be released. Visibility from other threads is no different to the case
where multiple pages locked by multiple threads.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
