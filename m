Date: Fri, 26 May 2000 17:40:18 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526174018.Q10082@redhat.com>
References: <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000526183640.A21731@pcep-jamie.cern.ch>; from lk@tantalophile.demon.co.uk on Fri, May 26, 2000 at 06:36:40PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, May 26, 2000 at 06:36:40PM +0200, Jamie Lokier wrote:

> That's ok.  VA == vma->pgoff + page_offset.  Move a vma and that's still
> true.  The ptes are found by looking at the list of all vmas referring
> to all the address_spaces that refer to a page.

And that is _exactly_ the problem --- especially with heavy mprotect()
use, processes can have enormous numbers of vmas.  Electric fence and
distributed shared memory/persistent object stores are the two big,
obvious cases here.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
