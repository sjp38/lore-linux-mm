Date: Fri, 17 Oct 2008 18:08:05 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 17 Oct 2008, Linus Torvalds wrote:
> 
> So maybe a better patch would be as follows? It simplifies the whole thing 
> by just always locking and unlocking the vma, whether it's newly allocated 
> or not (and whether it then gets dropped as unnecessary or not).

Side note: it would be nicer if we had a "spin_lock_init_locked()", so 
that we could avoid the more expensive "true lock" when doing the initial 
allocation, but we don't. That said, the case of having to allocate a new 
anon_vma _should_ be the rare one.

I dunno. Nick's approach of just depending on memory ordering for the list 
update probably works too. Even if it's rather more subtle than I'd like. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
