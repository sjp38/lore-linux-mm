Date: Fri, 14 Apr 2000 22:45:52 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: posix_fadvise
Message-ID: <20000414224552.A30555@pcep-jamie.cern.ch>
References: <m38zyhgn2a.fsf@localhost.localnet> <20000414105811.B29138@pcep-jamie.cern.ch> <m3snwofzo4.fsf@localhost.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m3snwofzo4.fsf@localhost.localnet>; from Ulrich Drepper on Fri, Apr 14, 2000 at 08:52:11AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@cygnus.com>
Cc: VGER kernel list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Chuck Lever <cel@monkey.org>
List-ID: <linux-mm.kvack.org>

Ulrich Drepper wrote:
> > What does POSIX_FADV_DONTNEED mean?  MADV_DONTNEED has at least three
> > incompatible meanings between different unix systems...
> 
> Their definition is:
> 
>   Specifies that the applicatione xpects that it will not access the
>   specified data in the near future.

Ok.  You should be aware that the present Linux implementation of
MADV_DONTNEED is "nukes dirty data".  Do you have a POSIX standard that
says POSIX MADV_DONTNEED should be similar to POSIX_FADV_DONTNEED?

There was some discussion on linux-mm about renaming this behaviour to
MADV_WONTNEED or MADV_DISCARD to avoid ambiguity.  Some other OSes
implement MADV_DONTNEED by discarding data, but there are at least two
other semantics around including one like POSIX_FADV_DONTNEED.

enjoy,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
