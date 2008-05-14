Date: Wed, 14 May 2008 02:44:56 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] mm: remove nopfn
Message-ID: <20080514004456.GB24516@wotan.suse.de>
References: <20080513074723.GB12869@wotan.suse.de> <20080513074829.GC12869@wotan.suse.de> <20080513154812.GA23256@sgi.com> <20080513162046.GA22407@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080513162046.GA22407@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 11:20:46AM -0500, Jack Steiner wrote:
> On Tue, May 13, 2008 at 10:48:12AM -0500, Jack Steiner wrote:
> > On Tue, May 13, 2008 at 09:48:29AM +0200, Nick Piggin wrote:
> > > There are no users of nopfn in the tree. Remove it.
> > > 
> > 
> > The SGI mspec driver use to use the nopfn callout. I see that this
> > was recently changed but the new code fails with:
> 
> Wait.... Looks like I missed the patch that deleted the BUG_ON. That should
> fix the problem (or at least change it).
> 
> Retesting.....

Thanks Jack, that would be a great help. Sorry, I should have cc'ed you
on the first patch as well so that it would be more clear that you have to
remove the BUG_ON.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
