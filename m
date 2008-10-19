Date: Sun, 19 Oct 2008 20:00:27 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0810191957300.16676@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
 <20081018013258.GA3595@wotan.suse.de>  <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
  <20081018022541.GA19018@wotan.suse.de>  <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
  <20081018052046.GA26472@wotan.suse.de> <1224326299.28131.132.camel@twins>
  <Pine.LNX.4.64.0810191048410.11802@blonde.site>
 <1224413500.10548.55.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Oct 2008, Linus Torvalds wrote:
> 
> Anyway, I _think_ the part that everybody agrees about is the initial 
> locking of the anon_vma. Whether we then even need any memory barriers 
> and/or the page_mapped() check is an independent question. Yes? No?
> 
> So I'm suggesting this commit as the part we at least all agree on. But I 
> haven't pushed it out yet, so you can still holler.. But I think all the 
> discussion is about other issues, and we all agree on at least this part?

I'll have to postpone answering the rest of your mail until later,
but yes, I agree your patch is what we've all agreed on so far,
and I can't even quibble with your description - it's good.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
