Date: Mon, 8 Oct 2007 10:41:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
In-Reply-To: <20071008133538.6ee6ad05@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0710081038050.26382@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0710081017000.26382@schroedinger.engr.sgi.com>
 <20071008133538.6ee6ad05@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007, Rik van Riel wrote:

> Due to the way swapin_readahead works (and how swapout works),
> it can easily end up pulling in another task's memory with the
> current task's NUMA allocation policy.

I am not sure what you mean by "another task's memory"? How does memory 
become owned by a task? 

Having a variety of NUMA allocation strategies applied to the pages of one 
file in memory is common for shared mmapped files like executables 
already.
 
> If that is an issue, we may want to change swapin_readahead to
> access nearby ptes and divine swap entries from those, only
> pulling in memory that really belongs to the current process.

Well lets keep it simple. The association of pages to a process is not 
that easy to establish if a page is shared.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
