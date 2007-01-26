Date: Fri, 26 Jan 2007 07:44:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Track mlock()ed pages
In-Reply-To: <20070126031300.59f75b06.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0701260742340.6141@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
 <45B9A00C.4040701@yahoo.com.au> <Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com>
 <20070126031300.59f75b06.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Andrew Morton wrote:

> > > > Track mlocked pages via a ZVC
> 
> Why?

Large amounts of mlocked pages may be a problem for 

1. Reclaim behavior.

2. Defragmentation


> You could perhaps go for a walk across all the other vmas which presently
> map this page.  If any of them have VM_LOCKED, don't increment the counter.
> Similar on removal: only decrement the counter when the final mlocked VMA
> is dropping the pte.

For that we would need an additional refcount for vmlocked maps in the 
page struct. Looks too expensive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
