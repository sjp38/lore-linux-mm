Date: Sat, 15 Jan 2005 20:53:11 +0800
From: Bernard Blackham <bernard@blackham.com.au>
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
Message-ID: <20050115125311.GA19055@blackham.com.au>
References: <20050113061401.GA7404@blackham.com.au> <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au> <20050113101426.GA4883@blackham.com.au> <41E8ED89.8090306@yahoo.com.au> <1105785254.13918.4.camel@desktop.cunninghams> <41E8F313.4030102@yahoo.com.au> <1105786115.13918.9.camel@desktop.cunninghams> <41E8F7F7.1010908@yahoo.com.au> <20050115124018.GA24653@blackham.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050115124018.GA24653@blackham.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: ncunningham@linuxmail.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 15, 2005 at 08:40:18PM +0800, Bernard Blackham wrote:
> On Sat, Jan 15, 2005 at 10:01:11PM +1100, Nick Piggin wrote:
> > Also, Bernard, can you try running with the following patch and
> > see what output it gives when you reproduce the problem?
> 
> On resuming:

And now with higher debug info that may prove useful (balance_pgdat
firing as soon as kswapd woken):

*** Cleaning up...
Free memory at 'out': 59157.
Last free mem was 59157. Is now 59156. I/O info        value 0 now -1.
Free memory at start of free_pagedir_data: 59156.
Last free mem was 59156. Is now 60013. Checksum pages  value 1 now 857.
Free memory at end of free_pagedir: 60013.
Pageset size1 was 3057; size2 was 2330.
Free memory after freeing pagedir data: 60013.
Thawing tasks
Waking     4: khelper.
Waking     5: kthread.
Waking     6: kacpid.
Waking     8: pdflush.
Waking    11: aio/0.
Waking    10: kswapd0.
Wakikswapd: balance_pgdat, order = 10
ng    12: jfsIO.
Waking    13: jfsCommit.
Waking    14: jfsSync.
Waking    15: kseriod.
Last free mem was 60013. Is now 60012. Start one       value 0 now -1.
Free memory at start of free_swap_pages_for_header: 60012.
[...]

HTH,

Bernard.

-- 
 Bernard Blackham <bernard at blackham dot com dot au>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
