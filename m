Date: Fri, 26 Jan 2007 03:13:00 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Track mlock()ed pages
Message-Id: <20070126031300.59f75b06.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
	<45B9A00C.4040701@yahoo.com.au>
	<Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007 22:36:17 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 26 Jan 2007, Nick Piggin wrote:
> 
> > Christoph Lameter wrote:
> > > Add NR_MLOCK
> > > 
> > > Track mlocked pages via a ZVC

Why?

> > I think it is not quite right. You are tracking the number of ptes
> > that point to mlocked pages, which can be >= the actual number of pages.
> 
> Mlocked pages are not inherited. I would expect sharing to be very rare.
>  
> > Also, page_add_anon_rmap still needs to be balanced with page_remove_rmap.
> 
> Hmmm.... 
>  
> > I can't think of an easy way to do this without per-page state. ie.
> > another page flag.
> 
> Thats what I am trying to avoid.

You could perhaps go for a walk across all the other vmas which presently
map this page.  If any of them have VM_LOCKED, don't increment the counter.
Similar on removal: only decrement the counter when the final mlocked VMA
is dropping the pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
