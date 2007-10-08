Date: Mon, 8 Oct 2007 10:52:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
In-Reply-To: <20071008134744.4b03f7e1@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0710081049460.29444@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0710081017000.26382@schroedinger.engr.sgi.com>
 <20071008133538.6ee6ad05@bree.surriel.com> <Pine.LNX.4.64.0710081038050.26382@schroedinger.engr.sgi.com>
 <20071008134744.4b03f7e1@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007, Rik van Riel wrote:

> > I am not sure what you mean by "another task's memory"? How does
> > memory become owned by a task? 
> 
> Swapin_readahead simply reads in all swap pages that are physically
> close to the desired one from the swap area, without taking into
> account whether or not the swap entry belongs to the current task
> or others.

That is the same approach used by regular readahead. Lee will only get 
back later in the week. He should take a look at this since he is trying 
to sort out the memory policy issues.

But that is more at the level of conceptual stuff that needs cleaning up

The patch is okay from what I can see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
