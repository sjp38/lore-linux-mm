Date: Fri, 6 Jun 2008 02:08:22 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/7] speculative page references, lockless pagecache, lockless gup
Message-ID: <20080606000822.GA16356@wotan.suse.de>
References: <20080605094300.295184000@nick.local0.net> <alpine.LFD.1.10.0806051031580.3473@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0806051031580.3473@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 05, 2008 at 10:33:15AM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 5 Jun 2008, npiggin@suse.de wrote:
> > 
> > I've decided to submit the speculative page references patch to get merged.
> > I think I've now got enough reasons to get it merged. Well... I always
> > thought I did, I just didn't think anyone else thought I did. If you know
> > what I mean.
> 
> So I'd certainly like to see these early in the 2.6.27 series. 
 
Oh good ;) So would I!


> Nick, will you just re-send them once 2.6.26 is out? Or do they cause 
> problems for Andrew and he wants to be part of the chain? I'm fine with 
> either.

Andrew has picked them up by the looks, and he's my favoured channel to
get mm work merged. Let's see how things go between now and 2.6.26,
which I assume should be a few weeks away?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
