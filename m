Date: Fri, 18 May 2001 23:12:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux 2.4.4-ac10
In-Reply-To: <20010518235852.R8080@redhat.com>
Message-ID: <Pine.LNX.4.21.0105182310580.5531-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mike Galbraith <mikeg@wen-online.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2001, Stephen C. Tweedie wrote:
> On Fri, May 18, 2001 at 07:44:39PM -0300, Rik van Riel wrote:
> 
> > This is the core of why we cannot (IMHO) have a discussion
> > of whether a patch introducing new VM tunables can go in:
> > there is no clear overview of exactly what would need to be
> > tunable and how it would help.
> 
> It's worse than that.  The workload on most typical systems is not
> static.  The VM *must* be able to cope with dynamic workloads.  You
> might twiddle all the knobs on your system to make your database run
> faster, but end up in such a situation that the next time a mail flood
> arrives for sendmail, the whole box locks up because the VM can no
> longer adapt.

That's another problem, indeed ;)

Ingo, Mike, please keep this in mind when designing
tunables or deciding which test you want to run today
in order to look how the VM is performing.


Basic rule for VM: once you start swapping, you cannot
win;  All you can do is make sure no situation loses
really badly and most situations perform reasonably.

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
