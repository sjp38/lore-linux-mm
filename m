Date: Fri, 13 Aug 1999 08:20:52 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Strange  memory allocation error in 2.2.11
In-Reply-To: <37B41E00.4D55F876@geocities.com>
Message-ID: <Pine.LNX.3.96.990813080203.24615A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Levenstein <romix@geocities.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Aug 1999, Roman Levenstein wrote:

> I'm writing a program , which actively uses garbage collection,
> implemented in
> a separate library(it scans stack, heap, etc. and relies on the system,
> when trying to determine start and end addresses of these memory areas ,
> but doesn't contain any assembler low-level code).

Hrmm, how exactly are you extracting this information from the kernel?

> Are there any changes in MM for 2.2.11 , which require recompilation of
> user programs? 

The only changes in 2.2.11 related to mm that could cause this have to do
with zeromapping ranges, but it should be a non-change for x86.  Also,
allocation patterns might be slightly different now as mmap is now allows
to wrap around once it reached the top of the address space.  Also, a bug
in mremap was fixed.

> What other reasons can lead to such effect?

Depends on your code =)  Do you have a test program that demonstrates the
but that we could look at?

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
