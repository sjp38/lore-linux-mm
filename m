Date: Tue, 9 May 2000 12:50:47 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <qww1z3bmxgc.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.10005091244270.1248-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Daniel Stone <tamriel@ductape.net>, riel@nl.linux.org, Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 9 May 2000, Christoph Rohland wrote:

> Linus Torvalds <torvalds@transmeta.com> writes:
> 
> > Try out the really recent one - pre7-8. So far it hassome good reviews,
> > and I've tested it both on a 20MB machine and a 512MB one..
> 
> Nope, does more or less lockup after the first attempt to swap
> something out. I can still run ls and free. but as soon as something
> touches /proc it locks up. Also my test programs do not do anything
> any more.

This may be due to an unrelated bug with the task_lock() fixing (see
separate patch from Manfred for that one).

> I append the mem and task info from sysrq. Mem info seems to not
> change after lockup.

I suspect that if you do right-alt + scrolllock, you'll see it looping on
a spinlock. Which is why the memory info isn't changing ;)

But I'll double-check the shm code (I didn't test anything that did any
shared memory, for example).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
