Date: Mon, 20 Oct 2008 20:25:54 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <200810211356.13191.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0810202024150.3287@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810200427270.5543@blonde.site> <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org> <200810211356.13191.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Tue, 21 Oct 2008, Nick Piggin wrote:
> >
> > So what I'm trying to figure out is why Nick wanted to add another check
> > for page_mapped(). I'm not seeing what it is supposed to protect against.
> 
> It's not supposed to protect against anything that would be a problem
> in the existing code (well, I initially thought it might be, but Hugh
> explained why its not needed). I'd still like to put the check in, in
> order to constrain this peculiarity of SLAB_DESTROY_BY_RCU to those
> couple of functions which allocate or take a reference.

Hmm.  Ok, as long as I understand what it is for (and if it's not a 
bug-fix but a "like to drop the stale anon_vma early), I'm ok.

So I won't mind, and Hugh seems to prefer it. So if you send that patch 
alogn with a good explanation for a changelog entry, I'll apply it.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
