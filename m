Date: Mon, 20 Oct 2008 04:26:39 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <Pine.LNX.4.64.0810190745420.5662@blonde.site>
Message-ID: <Pine.LNX.4.64.0810200421150.3867@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
 <20081018013258.GA3595@wotan.suse.de> <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
 <20081018022541.GA19018@wotan.suse.de> <Pine.LNX.4.64.0810181952580.27309@blonde.site>
 <20081019030325.GE16562@wotan.suse.de> <Pine.LNX.4.64.0810190745420.5662@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Oct 2008, Hugh Dickins wrote:
> On Sun, 19 Oct 2008, Nick Piggin wrote:
> > 
> > There is already a page_mapped check in there. I'm just going to
> > propose we move that down. No extra branchesin the fastpath. OK?
> 
> That should be OK, yes.  Looking back at the history, I believe
> I sited the page_mapped test where it is, partly for simpler flow,
> and partly to avoid overhead of taking spinlock unnecessarily.

Arrgh!  What terrible advice I gave you there, completely wrong:
that's what happens when I rush a reply instead of thinking.

I'm three-quarters through replying to Linus on this, and going
into that detail, remember now why its placement is critical.

Repeat the page_mapped check before returning if you wish,
but do not remove the one that's there: see other mail for
explanation.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
