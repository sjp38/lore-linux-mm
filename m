Date: Thu, 19 Apr 2001 01:25:46 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <0jurdtceqe39l7019vhckcgktk42m7bln1@4ax.com>
Message-ID: <Pine.LNX.4.30.0104190031190.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Apr 2001, James A. Sutherland wrote:
> >How you want to avoid "deadlocks" when running processes have
> >dependencies on suspended processes?
> If a process blocks waiting for another, the thrashing will be
> resolved.

This is a big simplification, e.g. not if it polls [not poll(2)].

> They will get this feedback, and more effectively than they do now:
> right now, they are left with a dead box they have to reboot. With

Not if they RTFM. Moreover thrashing != dead.

> IF you overload the system to extremes, then your processes will stop
> running for brief periods. Right now, they ALL stop running
> indefinitely!

This is not true. There *is* progress, it just can be painful slow.

> You haven't thought it through, then.

"If you don't learn from history .... ". Anyway get familiar with AIX.

But as I wrote before, I can't see problem with optional implementation
even I think the whole issue is a user space one and kernel efforts
should be concentrated fixing 2.4 MM bugs.

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
