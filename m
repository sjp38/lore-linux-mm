Date: Thu, 25 Jan 2007 22:36:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Track mlock()ed pages
In-Reply-To: <45B9A00C.4040701@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
 <45B9A00C.4040701@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Nick Piggin wrote:

> Christoph Lameter wrote:
> > Add NR_MLOCK
> > 
> > Track mlocked pages via a ZVC
> 
> I think it is not quite right. You are tracking the number of ptes
> that point to mlocked pages, which can be >= the actual number of pages.

Mlocked pages are not inherited. I would expect sharing to be very rare.
 
> Also, page_add_anon_rmap still needs to be balanced with page_remove_rmap.

Hmmm.... 
 
> I can't think of an easy way to do this without per-page state. ie.
> another page flag.

Thats what I am trying to avoid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
