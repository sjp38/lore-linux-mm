Date: Thu, 7 Oct 1999 15:40:32 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <14329.390.453805.801086@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9910061633250.29637-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Oct 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Mon, 4 Oct 1999 14:29:14 -0400 (EDT), James Simmons
> <jsimmons@edgeglobal.com> said:
> 
> > Okay. But none of this prevents a rogue app from hosing your system. Such
> > a process doesn't have to bother with locks or semaphores. 
> 
> And we talked about this before.  You _can_ make such a guarantee, but
> it is hideously expensive especially on SMP.  You either protect the
> memory or the CPU against access by the other app, and that requires
> either scheduler or VM interrupts between CPUs.

No VM stuff. I think the better approach is with the scheduler. The nice
thing about the schedular is the schedular lock. I'm assuming durning
is lock no other process on any CPU can be resceduled. Its during the lock
that I can test to see if a process is using a MMIO region that already in
use by another process. If it is then skip this process. If not weight
this process with the others. If a process is slected to be the next
executed process then lock the mmio region. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
