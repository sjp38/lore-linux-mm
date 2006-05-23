From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: tracking dirty pages patches
Date: Tue, 23 May 2006 14:17:05 -0700
Message-ID: <000001c67eae$3e29bd90$e734030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, Rohit Seth <rohitseth@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote on Tuesday, May 23, 2006 1:34 PM
> On Tue, 23 May 2006, Christoph Lameter wrote:
> > 
> > That is true for ia64. However, the name "lazy_mmu_prot_update" suggests
> > that the intended scope is to cover protection updates in general. 
> > And we definitely change the protections of the page.
> 
> True, and I now see Documentation/cachetlb.txt documents it that way.
> Yet nothing but ia64 has any use for it.
> 
> > Maybe we could rename lazy_mmu_prot_update? What does icache/dcache 
> > aliasing have to do with page protection?
> 
> I'd strongly agree with you that it should be renamed: for a start,
> why does it say "lazy"?  That's an architectural implementation detail.
> 
> Except that, instead of agreeing it should be renamed, I say it should
> be deleted entirely.  It seems to represent that ia64 has an empty
> update_mmu_cache, and someone decided to add a new interface instead
> of giving ia64 that work to do in its update_mmu_cache.

My memory recollects that it was done just like what you suggested:
overloading update_mmu_cache for ia64, but it was vetoed by several mm
experts.  And as a result a new function was introduced.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
