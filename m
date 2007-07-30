Date: Mon, 30 Jul 2007 06:35:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
Message-ID: <20070730043528.GC7222@wotan.suse.de>
References: <20070727021943.GD13939@wotan.suse.de> <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org> <20070727055406.GA22581@wotan.suse.de> <alpine.LFD.0.999.0707270811320.3442@woody.linux-foundation.org> <20070730030806.GA17367@wotan.suse.de> <alpine.LFD.0.999.0707292026190.4161@woody.linux-foundation.org> <alpine.LFD.0.999.0707292049420.4161@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707292049420.4161@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 29, 2007 at 08:56:54PM -0700, Linus Torvalds wrote:
> 
> 
> On Sun, 29 Jul 2007, Linus Torvalds wrote:
> > 
> > I'd love to hear "here's a real-life load, and yes, the ZERO_PAGE logic 
> > really does hurt more than it helps, it's time to remove it". At that 
> > point I'll happily apply the patch.
> 
> Btw, in the absense of that, I'd at least like to hear an acknowledgement 
> that the complexity isn't worth it, and that what used to work fine was 
> broken because the reference counting overhead gets us on large-scale 
> machines.
> 
> IOW, I certainly like removing lines of code. In that sense I _love_ that 
> patch. I really just react negatively because I really think you first set 
> ZERO_PAGE up to fail.
> 
> So even if you cannot find a load where this all matters, at least point 
> to commit b5810039a54e5babf428e9a1e89fc1940fabff11 (or exactly whichever 
> one it was that started ref-counting ZERO_PAGE) and blame *that* one, 
> rather than blaming ZERO_PAGE for the problem.

OK, as a patch, the changelog could be improved. But I state that
complexity isn't worth it as "ZERO_PAGE appears to be a false optimisation".


> It has served us well for fifteen years, we shouldn't blame it for 
> problems that came from elsewhere.

Can it still serve us well, though? This is what I would really like to talk
about, and I guess would decide whether we again special case the refcounting
or remove it completely. I'm happy to do either (although I do *hope* that it
can be removed, for complexity's sake).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
