Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id D6C8C16B1B
	for <linux-mm@kvack.org>; Wed, 18 Apr 2001 19:29:26 -0300 (EST)
Date: Wed, 18 Apr 2001 19:29:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <Pine.LNX.4.30.0104190031190.20939-100000@fs131-224.f-secure.com>
Message-ID: <Pine.LNX.4.33.0104181918290.17635-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Szabolcs Szakacsits wrote:

> > They will get this feedback, and more effectively than they do now:
> > right now, they are left with a dead box they have to reboot. With
>
> Not if they RTFM. Moreover thrashing != dead.
>
> > IF you overload the system to extremes, then your processes will stop
> > running for brief periods. Right now, they ALL stop running
> > indefinitely!
>
> This is not true. There *is* progress, it just can be painful slow.

"Painfully slow" when you are thrashing  ==  "root cannot login
because his login times out every time he tries to login".

THIS is why we need process suspension in the kernel.

Also think about the problem a bit more.  If the "painfully slow
progress" is getting less work done than the amount of new work
that's incoming (think of eg. a mailserver), then the system has
NO WAY to ever recover ... at least, not without the system
administrator walking by after the weekend.

OTOH, when the kernel suspends SOME tasks, so the others can run
at full speed (and then switches, etc..), then the system is able
to run all tasks to completion and crawl out of the overload
situation.


This is nothing different from CPU scheduling, except that this
happens on a larger timescale and is only done to rescue the system
in an emergency.    Or did you want to get rid of preemptive
multitasking too ?

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
