From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Wed, 18 Apr 2001 21:38:26 +0100
Message-ID: <0jurdtceqe39l7019vhckcgktk42m7bln1@4ax.com>
References: <Pine.LNX.4.21.0104171648010.14442-100000@imladris.rielhome.conectiva> <Pine.LNX.4.30.0104182315010.20939-100000@fs131-224.f-secure.com>
In-Reply-To: <Pine.LNX.4.30.0104182315010.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Apr 2001 23:32:25 +0200 (MET DST), you wrote:

>On Tue, 17 Apr 2001, Rik van Riel wrote:
>> On Mon, 16 Apr 2001, Szabolcs Szakacsits wrote:
>> > Please don't. Or at least make it optional and not the default or user
>> > controllable. Trashing is good.
>> This sounds like you have no idea what thrashing is.
>
>Sorry, your comment isn't convincing enough ;) Why do you think
>"arbitrarily" (decided exclusively by the kernel itself) suspending
>processes (that can be done in user space anyway) would help?

Not "arbitrarily"; they will be frozen for increasing periods of time.
Effectively just a huge increase in timeslice size.

>Even if you block new process creation and memory allocations (that's
>also not nice since it can be done by resource limits) why you think
>situation will ever get better i.e. processes release memory?

Only a pathological workload will lead to indefinite thrashing; in
this, worst case, scenario this approach makes no real difference. In
any other scenario, it's a major improvement.

>How you want to avoid "deadlocks" when running processes have
>dependencies on suspended processes?

If a process blocks waiting for another, the thrashing will be
resolved.

>What control you plan for sysadmins who *want* to get feedback about bad
>setups as soon as possible?

They will get this feedback, and more effectively than they do now:
right now, they are left with a dead box they have to reboot. With
this solution, a few resource hog processes get suspended briefly.

>How you plan to explain on comp.os.linux.development.applications
>that your *perfect* programs can't only be SIGKILL'd by kernel at any
>time but also suspended for indefinite time from now?

IF you overload the system to extremes, then your processes will stop
running for brief periods. Right now, they ALL stop running
indefinitely!

>Sure it would help in cases and in others it would utterly fail. 

Nope. Allowing the system to thrash IS the worst case scenario!

>Just
>like the thrasing case. So as such I see it an unnecessary bloat adding
>complexity and no real functionality.

You haven't thought it through, then. Thrashing is the worst-case
endgame scenario: all bets are off. ANYTHING, including SIGKILLing
RANDOM processes, is better than that.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
