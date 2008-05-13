Date: Tue, 13 May 2008 10:01:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080513080143.GB19870@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org> <20080506095138.GE10141@wotan.suse.de> <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 07:53:23AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 6 May 2008, Nick Piggin wrote:
> > 
> > Right. As the comment says, the x86 stuff is kind of a "reference"
> > implementation, although if you prefer it isn't there, then I I can
> > easily just make it alpha only.
> 
> If there really was a point in teaching people about 
> "read_barrier_depends()", I'd agree that it's probably good to have it as 
> a reference in the x86 implementation.
> 
> But since alpha is the only one that needs it, and is likely to remain so, 
> it's not like we ever want to copy that code to anything else, and it 
> really is better to make it alpha-only if the code is so much uglier.

No, *everyone* (except arch-only non-alpha developer) needs to know about
it.

x86 especially is a reference and often is a proving ground for code that
becomes generic, so I'd say even x86 developers should need to know about
it too.

 
> Maybe just a comment?

At the end of the day I don't care that much. I'm surprised you do,
but I'll do whatever it takes to get merged ;) 


> As to the ACCESS_ONCE() thing, thinking about it some more, I doubt it 
> really matters. We're never going to change pgd anyway, so who cares if we 
> access it once or a hundred times?

I will just re-review that I have my pointer following sequence correct,
it could be that I have one too many... but anyway it is needed for lower
levels I guess (as a general pattern -- in the actual case of pagetable
walking, I don't think it matters anywhere if a pointer gets refetched
after being dereferenced)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
