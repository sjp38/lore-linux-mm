Date: Fri, 26 May 2000 19:02:08 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526190208.A21856@pcep-jamie.cern.ch>
References: <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch> <20000526174018.Q10082@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000526174018.Q10082@redhat.com>; from sct@redhat.com on Fri, May 26, 2000 at 05:40:18PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > That's ok.  VA == vma->pgoff + page_offset.  Move a vma and that's still
> > true.  The ptes are found by looking at the list of all vmas referring
> > to all the address_spaces that refer to a page.
> 
> And that is _exactly_ the problem --- especially with heavy mprotect()
> use, processes can have enormous numbers of vmas.  Electric fence and
> distributed shared memory/persistent object stores are the two big,
> obvious cases here.

The stacked private address_spaces I described don't have to be shared
between address_spaces in a single mm.  You can have one per vma --
that's simple but maybe wasteful.  Or one per several vmas.  When you
divide a single vma into zillions using mprotect(), you're free to split
off new spaces to limit the number of vmas per space.

-- Jamie








> 
> --Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
