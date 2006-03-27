Message-ID: <4427353A.6060905@yahoo.com.au>
Date: Mon, 27 Mar 2006 10:43:38 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless pagecache perhaps for 2.6.18?
References: <20060323081100.GE26146@wotan.suse.de> <200603262021.46276.ncunningham@cyclades.com>
In-Reply-To: <200603262021.46276.ncunningham@cyclades.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@cyclades.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Nigel Cunningham wrote:

> Can I get a pointer to the patches and any docs please? Since I save the page 
> cache separately, I'd need a good understanding of the implications of the 
> changes.
> 

Hi Nigel,

http://www.kernel.org/pub/linux/kernel/people/npiggin/patches/lockless/2.6.16-rc5/

There are some patches... a lot of them, but only the last 5 in the series
matter (the rest are pretty much in 2.6.16-head).

There is also a small doc on the lockless radix-tree in that directory. I'm in
the process of writing some documentation on the lockless pagecache itself...

You probably don't need to worry too much unless you are testing page_count()
under the tree_lock, held for writing, expecting that to stabilise page_count.
In which case I could have a look at your code and see if it would be a
problem.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
