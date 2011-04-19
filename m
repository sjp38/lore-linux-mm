Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 94BB08D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 18:04:35 -0400 (EDT)
Date: Tue, 19 Apr 2011 17:04:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: fix panic with DISCONTIGMEM
In-Reply-To: <1303249970.11237.30.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104191702400.26867@router.home>
References: <1303248576.11237.23.camel@mulgrave.site>  <alpine.DEB.2.00.1104191633250.23077@router.home> <1303249970.11237.30.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, Parisc List <linux-parisc@vger.kernel.org>

On Tue, 19 Apr 2011, James Bottomley wrote:

> On Tue, 2011-04-19 at 16:38 -0500, Christoph Lameter wrote:
> > On Tue, 19 Apr 2011, James Bottomley wrote:
> >
> > > Slub makes assumptions about page_to_nid() which are violated by
> > > DISCONTIGMEM and !NUMA.  This violation results in a panic because
> >
> > Fix this by stating correctly by saying "The kernel makes assumptions in
> > various subsystems ..."
>
> Slub is a subset of the kernel, so the original wording is a bit more
> precise.

F.e. hugepage support does the same thing. So it not slub specific.

> Well, we can discuss how to proceed going forwards.  The current fact is
> that any prior kernel that enables SLUB with DISCONTIGMEM and !NUMA will
> eventually go boom when the page allocator returns a page not in the
> first pfn array.  That has to be fixed in -stable.  I don't really think
> a DISCONTIGMEM re-engineering effort would be the best thing for the
> -stable series.

As far as I can tell: It will go boom even with other subsystems. I am
surprised that we have never seen this before.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
