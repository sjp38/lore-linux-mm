Date: Fri, 20 Apr 2001 14:18:34 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <11530000.987705299@baldur>
Message-ID: <Pine.LNX.4.30.0104201223390.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmc@austin.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Dave McCracken wrote:
> --On Wednesday, April 18, 2001 23:32:25 +0200 Szabolcs Szakacsits
> > How you want to avoid "deadlocks" when running processes have
> > dependencies on suspended processes?
> I think there's a semantic misunderstanding here.  If I understand Rik's
> proposal right, he's not talking about completely suspending a process ala
> SIGSTOP.  He's talking about removing it from the run queue for some small
> length of time (ie a few seconds, probably) during which all the other
> processes can make progress.

Yes, I also didn't mean deadlocks in its classical sense this is the
reason I put it in quote. The issue is the unexpected potentially huge
communication latencies between processes/threads or between user and
system. App developers do write code taking load/latency into account
but not in mind some of their processes/threads can get suspended for
indeterminated interval from time to time.

> This kind of suspension won't be noticeable to users/administrators
> or permanently block dependent processes.  In fact, it should make
> the system appear more responsive than one in a thrashing state.

With occasionally suspended X, sshd, etc, etc, etc ;)

	Szaka


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
