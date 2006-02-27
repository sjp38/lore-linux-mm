Date: Mon, 27 Feb 2006 17:23:09 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.64.0602270837460.2849@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0602271658240.8669@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270837460.2849@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Christoph Lameter wrote:
> 
> That is a rather subtle thing not evident from the code. Add another 
> comment?

I won't fight if you insist on doing so, but it's already proclaimed
itself to be tricky, with lengthy comments in mm/slab.c and now here.
At some stage, I think, we need to stop reading comments and ponder
the code itself.

> Or better do the rcu locking before calling page_lock_anon_vma 
> and the unlocking after spin_unlock to have proper nesting of locks?

No, page_lock_anon_vma is all about insulating the rest of the code
from these difficulties: I do prefer it as is.

That said, I had mixed feelings when the name "rcu_read_lock" was
introduced: it's not always helpful to distinguish it from
preempt_disable in that way.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
