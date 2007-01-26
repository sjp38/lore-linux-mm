Date: Fri, 26 Jan 2007 10:10:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Track mlock()ed pages
Message-Id: <20070126101027.90bf3e63.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701260742340.6141@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
	<45B9A00C.4040701@yahoo.com.au>
	<Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com>
	<20070126031300.59f75b06.akpm@osdl.org>
	<Pine.LNX.4.64.0701260742340.6141@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007 07:44:42 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 26 Jan 2007, Andrew Morton wrote:
> 
> > > > > Track mlocked pages via a ZVC
> > 
> > Why?
> 
> Large amounts of mlocked pages may be a problem for 
> 
> 1. Reclaim behavior.
> 
> 2. Defragmentation
> 

We know that.  What has that to do with this patch?

> 
> > You could perhaps go for a walk across all the other vmas which presently
> > map this page.  If any of them have VM_LOCKED, don't increment the counter.
> > Similar on removal: only decrement the counter when the final mlocked VMA
> > is dropping the pte.
> 
> For that we would need an additional refcount for vmlocked maps in the 
> page struct.

No you don't.  The refcount is already there.  It is "the sum of the VM_LOCKED
VMAs which map this page".

It might be impractical or expensive to calculate it, but it's there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
