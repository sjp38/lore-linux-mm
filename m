Date: Sat, 21 Apr 2007 08:24:24 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
In-Reply-To: <462932BE.4020005@redhat.com>
Message-ID: <Pine.LNX.4.64.0704210818580.25689@blonde.wat.veritas.com>
References: <46247427.6000902@redhat.com> <20070420135715.f6e8e091.akpm@linux-foundation.org>
 <462932BE.4020005@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007, Rik van Riel wrote:
> Andrew Morton wrote:
> 
> >   I do go on about that.  But we're adding page flags at about one per
> >   year, and when we run out we're screwed - we'll need to grow the
> >   pageframe.
> 
> If you want, I can take a look at folding this into the
> ->mapping pointer.  I can guarantee you it won't be
> pretty, though :)

Please don't.  If we're going to stuff another pageflag into there,
let it be PageSwapCache the natural partner of PageAnon, rather than
whatever our latest pageflag happens to be.  I'll look into it - but
do keep an eye on me, I've developed a dubious track record of
obstructing other people's attempts to save pageflags.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
