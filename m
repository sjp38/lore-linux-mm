Date: Fri, 26 May 2000 19:05:55 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526190555.B21856@pcep-jamie.cern.ch>
References: <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch> <20000526174018.Q10082@redhat.com> <200005261655.JAA90389@apollo.backplane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200005261655.JAA90389@apollo.backplane.com>; from dillon@apollo.backplane.com on Fri, May 26, 2000 at 09:55:47AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Dillon wrote:
>     In regards to overhead, anything that collects a bunch of pages together
>     (e.g. vm_map_entry, vm_object under FBsd, VMA in Jamie's scheme)
>     simply does not create a memory overhead issue.  None at all.  It's
>     the things that eat memory on a per-page basis that get annoying.

Stephen's point is that there are applications which use mprotect() on a
per-page basis.  Some garbage collectors for example, to track dirtied
pages.

And having to scan hundreds of vmas to find one pte sucks :-)

But I addressed that a few minutes ago.  In my scheme you don't have to
scan lots of vmas to find that pte.  Only one or two, or you can choose
to increase that number while decreasing memory requirements a little.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
