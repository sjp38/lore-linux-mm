Date: Fri, 26 May 2000 10:35:30 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005261735.KAA90570@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
References: <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch> <20000526174018.Q10082@redhat.com> <200005261655.JAA90389@apollo.backplane.com> <20000526190555.B21856@pcep-jamie.cern.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

:Matthew Dillon wrote:
:>     In regards to overhead, anything that collects a bunch of pages together
:>     (e.g. vm_map_entry, vm_object under FBsd, VMA in Jamie's scheme)
:>     simply does not create a memory overhead issue.  None at all.  It's
:>     the things that eat memory on a per-page basis that get annoying.
:
:Stephen's point is that there are applications which use mprotect() on a
:per-page basis.  Some garbage collectors for example, to track dirtied
:pages.
:
:And having to scan hundreds of vmas to find one pte sucks :-)
:
:But I addressed that a few minutes ago.  In my scheme you don't have to
:scan lots of vmas to find that pte.  Only one or two, or you can choose
:to increase that number while decreasing memory requirements a little.
:
:-- Jamie

    Hmm.  I know apps which use madvise() to manage allocated/free pages
    efficiently, but not any that use mprotect().  The madvise() flags 
    typically used effect the underlying pages directly and should not fragment
    the VMA's at all.  In anycase, it's not a big deal because even if you
    did have to fragment the VMA's, you can still collapse adjacent entries
    together.  i.e. if the garbage collector protects page 1 and then later
    on protects page 2 the same way, you still need only one VMA to
    represent both pages.

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
