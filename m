Date: Thu, 14 Sep 2006 17:20:57 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] Don't set/test/wait-for radix tree tags if no capability
In-Reply-To: <1158249131.5416.20.camel@localhost>
Message-ID: <Pine.LNX.4.64.0609141704270.7652@blonde.wat.veritas.com>
References: <1158176114.5328.52.camel@localhost>
 <Pine.LNX.4.64.0609131350030.19101@schroedinger.engr.sgi.com>
 <1158185559.5328.82.camel@localhost>  <Pine.LNX.4.64.0609141559300.3122@blonde.wat.veritas.com>
 <1158249131.5416.20.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Sep 2006, Lee Schermerhorn wrote:
> 
> So, I guess I shouldn't worry too much about why swapin_readahead() is
> in mm/memory.c instead of one of the mm/swap*.c files, huh?

Don't worry too much about it, indeed; though I agree it'd be much
nicer tucked away somewhere else, near read_swap_cache_async or
near valid_swaphandles or the three brought together.

(But if you do want to worry about swapin_readahead, just savour the
absurdity of its NUMA next_vma code: just what is the likelihood that
swap allocation will match a task's address layout?)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
