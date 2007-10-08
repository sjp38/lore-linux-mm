Date: Mon, 8 Oct 2007 14:48:53 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
Message-ID: <20071008144853.33aee7be@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710081049460.29444@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710081017000.26382@schroedinger.engr.sgi.com>
	<20071008133538.6ee6ad05@bree.surriel.com>
	<Pine.LNX.4.64.0710081038050.26382@schroedinger.engr.sgi.com>
	<20071008134744.4b03f7e1@bree.surriel.com>
	<Pine.LNX.4.64.0710081049460.29444@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007 10:52:35 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 8 Oct 2007, Rik van Riel wrote:
> 
> > > I am not sure what you mean by "another task's memory"? How does
> > > memory become owned by a task? 
> > 
> > Swapin_readahead simply reads in all swap pages that are physically
> > close to the desired one from the swap area, without taking into
> > account whether or not the swap entry belongs to the current task
> > or others.
> 
> That is the same approach used by regular readahead.

Yes, but in regular readahead you can generally assume that the data
within one file will be related.  You can make no such assumption with
swap.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
