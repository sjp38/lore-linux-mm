Date: Fri, 25 Feb 2000 12:55:19 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] kswapd performance fix
In-Reply-To: <14518.22746.519992.127418@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.10002251250450.24051-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, "Stephen Tweedie <sct@redhat.com> Linux Kernel" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Feb 2000, Stephen C. Tweedie wrote:
> On Fri, 25 Feb 2000 00:30:59 +0100 (CET), Rik van Riel
> <riel@nl.linux.org> said:
> 
> > The patch should apply to any 2.2 or 2.3 kernel, but for
> > 2.3 it'll have the interesting side effect of nullifying
> > the (minimal) page aging that's going on there.
> 
> Have you actually tested the impact of this under a variety of
> load conditions?  In the past we have seen such apparently trivial
> changes completely break the VM balance under certain loads.

The PG_referenced bit isn't used for anything except for
NRU/LRU page reclaiming in shrink_mmap().

However, shrink_mmap() will skip over any pages that are
still mapped by processes _and_ when we unmap the page
from the (next to) last user we set the PG_referenced bit.

The PG_referenced bit is also not used at all by shrink_mmap(),
unless (page->count == 1); shm_swap() doesn't use the referenced
bit at all.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
