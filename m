Date: Mon, 17 Oct 2005 17:14:38 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Patch 2/3] Export get_one_pte_map.
In-Reply-To: <20051017155605.GB2564@lnx-holt.americas.sgi.com>
Message-ID: <Pine.LNX.4.61.0510171700150.4934@goblin.wat.veritas.com>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com>
 <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com>
 <20051017113131.GA30898@lnx-holt.americas.sgi.com> <1129549312.32658.32.camel@localhost>
 <20051017114730.GC30898@lnx-holt.americas.sgi.com>
 <Pine.LNX.4.61.0510171331090.2993@goblin.wat.veritas.com>
 <20051017151430.GA2564@lnx-holt.americas.sgi.com> <20051017152034.GA32286@kroah.com>
 <20051017155605.GB2564@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Greg KH <greg@kroah.com>, Dave Hansen <haveblue@us.ibm.com>, ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Carsten Otte <cotte@de.ibm.com>, Jack Steiner <steiner@americas.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Oct 2005, Robin Holt wrote:
> On Mon, Oct 17, 2005 at 08:20:34AM -0700, Greg KH wrote:
> > 
> > The stuff in -mm is what is going to be in .15, so you have to work off
> > of that patchset if you wish to have something for .15.

The stuff in -mm is a best guess at what's going to be in 2.6.15,
but it's far from exact and certain.

> Is everything in the mm/ directory from the -mm tree going into .15 or
> is there a planned subset?  What should I develop against to help ensure
> I match up with the community?

That's a question for Andrew (added to CC in case he's not receiving
enough copies of this mail ;-), and it's too soon to tell - changes
which have only just been exposed in 2.6.14-rc4-mm1 are not yet
mature enough for a judgement.

I've still got stuff to come, to make full sense of what's already in:
if I were Andrew, given the faster releases we're going for now, I'd
currently be in some doubt about whether to push that for 2.6.15.

Perhaps he'll be more comfortable with yours, feel it's the right
way to go, and want to put it ahead of what's presently in -mm.
Or perhaps not.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
