Date: Wed, 31 Aug 2005 14:42:38 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/1] Implement shared page tables
In-Reply-To: <1125489077.3213.12.camel@laptopd505.fenrus.org>
Message-ID: <Pine.LNX.4.61.0508311437070.16834@goblin.wat.veritas.com>
References: <7C49DFF721CB4E671DB260F9@[10.1.1.4]>
 <Pine.LNX.4.61.0508311143340.15467@goblin.wat.veritas.com>
 <1125489077.3213.12.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Aug 2005, Arjan van de Ven wrote:
> On Wed, 2005-08-31 at 12:44 +0100, Hugh Dickins wrote:
> > I was going to say, doesn't randomize_va_space take away the rest of
> > the point?  But no, it appears "randomize_va_space", as it currently
> > appears in mainline anyway, is somewhat an exaggeration: it just shifts
> > the stack a little, with no effect on the rest of the va space.
> 
> it also randomizes mmaps

Ah, via PF_RANDOMIZE, yes, thanks: so long as certain conditions are
fulfilled - and my RLIM_INFINITY RLIMIT_STACK has been preventing it.

And mmaps include shmats: so unless the process specifies non-NULL
shmaddr to attach at, it'll choose a randomized address for that too
(subject to those various conditions).

Which is indeed a further disincentive against shared page tables.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
