Subject: Re: tracking dirty pages patches
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0605241558380.12355@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0605230917390.9731@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0605231937410.14985@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0605231223360.10836@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
	 <1148437514.3049.18.camel@laptopd505.fenrus.org>
	 <Pine.LNX.4.64.0605241558380.12355@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Thu, 25 May 2006 04:26:33 +0200
Message-Id: <1148523993.3052.6.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Rohit Seth <rohitseth@google.com>, David Howells <dhowells@redhat.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-05-24 at 16:10 +0100, Hugh Dickins wrote:
> On Wed, 24 May 2006, Arjan van de Ven wrote:
> > On Tue, 2006-05-23 at 21:34 +0100, Hugh Dickins wrote:
> > 
> > > You mentioned in one of the mails that went past that you'd seen
> > > drivers enforcing VM_LOCKED in vm_flags: aren't those just drivers
> > > copying other drivers which did so, but achieving nothing thereby,
> > > to be cleaned up in due course?  (The pages aren't even on LRU.)
> > 
> > I would like to know which, because in general this is a security hole:
> > Any driver that depends on locked meaning "doesn't move" can be fooled
> > by the user into becoming unlocked... (by virtue of having another
> > thread do an munlock on the memory). As such no kernel driver should 
> > depend on this, and as far as I know, no kernel driver actually does.
> 
> You'll have seen the list in Christoph's patch.  But they're all
> remap_pfn_range users, largely copied one from another, and their
> pages won't become freeable even if the user munlocks.

that's not "real memory" though so not too relevant for the scenario I
had in mind...
> 
> However, that munlocking will lower locked_vm when it shouldn't
> touch it.  I suppose the ingenious might mmap and munmap such a
> driver in order to lock another mapping beyond RLIMIT_MEMLOCK.
> Perhaps that raises the priority of Christoph's patch?

... but yes that also makes it a security issue, although a bit less
severe I suppose


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
