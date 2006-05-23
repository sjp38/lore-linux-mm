Date: Tue, 23 May 2006 14:16:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: tracking dirty pages patches
In-Reply-To: <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0605231403580.11560@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605230917390.9731@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605231937410.14985@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605231223360.10836@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, Rohit Seth <rohitseth@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2006, Hugh Dickins wrote:

> > Page migration currently also assumes that VM_LOCKED means do not move the 
> > page. At some point we may want to have a separate flag that guarantees
> > that a page should not be moved. This would enable the moving of VM_LOCKED 
> > pages.
> 
> Oh yes, I'd noticed that subject going by, and meant to speak up
> sometime.  I feel pretty strongly, and have so declared in the past,
> that VM_LOCKED should _not_ guarantee that the same physical page is
> used forever: get_user_pages is what's used to pin a physical page
> for that effect.  I remember Arjan sharing this opinion.
> 
> You might discover a problem or two in letting page migration go that
> way, I'm not saying there cannot be a problem; but I'd much rather
> you try without adding a new flag unless it's proved necessary.
> And I know Linus prefers not to go overboard with extra flags.

Ok. I thought that there would be a requirement to have such a flag 
instead of VM_LOCKED.
 
> You mentioned in one of the mails that went past that you'd seen
> drivers enforcing VM_LOCKED in vm_flags: aren't those just drivers
> copying other drivers which did so, but achieving nothing thereby,
> to be cleaned up in due course?  (The pages aren't even on LRU.)

Could be. I think Kame looked at the drivers. The memory hotplug people 
are mostly interested in moving VM_LOCKED pages. I would like to support 
them in that but we have currently no need to move mlocked pages.

Pages that are not on the LRU cannot be moved by page migration. So maybe 
that kind of condition is sufficient to pin memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
