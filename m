Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 77A495F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:38:42 -0400 (EDT)
Date: Mon, 1 Jun 2009 22:11:42 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
 in the VM v3
In-Reply-To: <20090601140553.GA1979@localhost>
Message-ID: <Pine.LNX.4.64.0906012138170.27344@sister.anvils>
References: <200905271012.668777061@firstfloor.org>
 <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de>
 <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de>
 <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de>
 <20090601140553.GA1979@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jun 2009, Wu Fengguang wrote:
> On Mon, Jun 01, 2009 at 07:50:46PM +0800, Nick Piggin wrote:
> > On Thu, May 28, 2009 at 09:54:28PM +0800, Wu Fengguang wrote:
> > > On Thu, May 28, 2009 at 08:23:57PM +0800, Nick Piggin wrote:
> > > >
> > > > Should all be commented and put into mm/swap_state.c (or somewhere that
> > > > Hugh prefers).
> > >
> > > But I doubt Hugh will welcome moving that bits into swap*.c ;)
> >
> > Why not? If he has to look at it anyway, he probably rather looks
> > at fewer files :)
> 
> Heh. OK if that's more convenient - not a big issue for me really.

Sorry for being so elusive, leaving you all guessing: it's kind of
you to consider me at all.  As I remarked to Andi in private mail
earlier, I'm so far behind on my promises (especially to KSM) that
I don't expect to be looking at HWPOISON for quite a while.

I don't think I'd mind about the number of files to look at.

Generally I agree with Nick, wanting the rmap-ish code to be in rmap.c
and the swap_state-ish code to be in swap_state.c and the swapfile-ish
code to be in swapfile.c etc.  (Though it's an acquired skill to work
out which is which of those two - one thing you can be sure of though,
if it's swap-related code, swap.c is strangely not the place for it.
Yikes, someone put swap_setup in there.)

But like most of us, I'm not so keen on #ifdefs: am I right to think
that if you distribute the hwpoison code around in its appropriate
source files, we'll have a nasty rash of #ifdefs all over?  We can
sometimes get away with the optimizer removing what's not needed,
but that only works in the simpler cases.

Maybe we should start out, as you have, with most of the hwpoison
code located in one file (rather like with migrate.c?); but hope
to refactor things and distribute it over time.

How seriously does the hwpoison work interfere with the assumptions
in other sourcefiles?  If it's playing tricks liable to confuse
someone reading through those other files, then it would be better
to place the hwpoison code in those files, even though #ifdefed.

There, how's that for a frustratingly equivocal answer?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
