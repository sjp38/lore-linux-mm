Subject: Re: MMIO regions
References: <199910101124.HAA32129@light.alephnull.com> 	<m1emf3wbxc.fsf@alogconduit1ai.ccr.net> <14336.53971.896012.84699@light.alephnull.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 10 Oct 1999 22:38:41 -0500
In-Reply-To: Rik Faith's message of "Sun, 10 Oct 1999 14:46:05 -0400 (EDT)"
Message-ID: <m1zoxqva66.fsf@alogconduit1ai.ccr.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik Faith <faith@precisioninsight.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, James Simmons <jsimmons@edgeglobal.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik Faith <faith@precisioninsight.com> writes:

> (http://precisioninsight.com/dr/security.html).
References read and digested.

I am now convinced that (given buggy hardware) the software lock
is the only possible way to go.

The argument is that unless the hardware is well designed you cannot
save it's state to do a context switch at arbitrary times.
A repeat of the old EGA problem.

The second part of the architecture is that openGL does the rendiring
in the X server with the same libraries as in user space, with the addition
of a loop to fetch the commands to run, from another process.

And the openGL would be the only API programmed to.
With dispatch logic similiar to that found in libggi, for different
hardware.  And it would only be in the hardware specific code that the
lock would be taken if needed.

The fact that in this interface the kernel will only expose safe
hardware registers makes this design not as spooky.  The spooky aspect
is still remains in that incorrectly accessing the hardware, (possibly
caused by a stray pointer) can cause a system crash.

The nice thing is if you remove SGID bit from the binaries, all
rendering will be indirect through the X server, allowing security to
be managed. 

The previous are from SGI & HP suggests that with good hardware
a page faulting technique may be prefered for fairness etc.
There are many issues relating to TLB flushes, and multithread
programs that need to be resolved, but that is mostly irrelevant
as most hardware is too buggy to properly context switch :(

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
