From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] mm: dirty page tracking race fix
Date: Mon, 18 Aug 2008 18:12:17 +1000
References: <20080818053821.GA3011@wotan.suse.de> <200808181803.57730.nickpiggin@yahoo.com.au> <1219046833.10800.270.camel@twins>
In-Reply-To: <1219046833.10800.270.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808181812.17595.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Monday 18 August 2008 18:07, Peter Zijlstra wrote:
> On Mon, 2008-08-18 at 18:03 +1000, Nick Piggin wrote:
> > On Monday 18 August 2008 17:49, Peter Zijlstra wrote:
> > > On Mon, 2008-08-18 at 07:38 +0200, Nick Piggin wrote:
> > > > It's possible to retain this optimization for page_referenced and
> > > > try_to_unmap.
> > >
> > > s/synch/sync/ ?
> > >
> > > we use sync all over the kernel to mean synchonous, so why are you
> > > inventing a new shorthand?
> >
> > Mmm, we also use synch all over the kernel to mean synchronous,
> > including in mm/, so I'm not inventing a new shorthand. sync I
> > see is more common, but it's not something anybody would get
> > confused about is it?
>
> I hadn't noticed before, and my grep skillz seem to have left me in the
> cold
>
> git grep "\<synch\>" mm/* | wc -l
> 0

"asynch" ;) 1 hit! So *technically* I'm wrong...


> And you're right, its not something one can get confused about. So lets
> just keep it unless someone else objects ;-)

Andrew feel free to edit the patch if/when you pick it up :P

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
