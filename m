From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sat, 21 Apr 2001 06:49:44 +0100
Message-ID: <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com>
References: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com> <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
In-Reply-To: <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Dave McCracken <dmc@austin.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2001 14:14:29 +0200 (MET DST), you wrote:
>On Thu, 19 Apr 2001, James A. Sutherland wrote:
>
>> That's my suspicion too: The "strangled" processes eat up system
>> resources and still get nowhere (no win there: might as well suspend
>> them until they can run properly!) and you are wasting resources which
>> could be put to good use by other processes.
>
>You assumes processes are completely equal or their goodnesses are based
>on their thrasing behavior. No. Processes are not like that from user
>point of view (admins, app developers) moreover they can have complex
>relationships between them.

How do you think I am assuming this? The kernel already suspends and
resumes processes all the time!

>Kernel must give mechanisms to enforce policies, not to dictate them.
>And this can be done even at present. You want to create and solve a
>problem that doesn't exist because you don't want to RTFM.

"RTFM" does not solve this problem. All the manual in question could
say is "add more RAM" or "kill some processes". That's not very
useful.

>> More to the point, though, what about the worst case, where every
>> process is thrashing?
>
>What about the simplest case when one process thrasing? 

Tell me how one process can be starving ITSELF of resources?!

>You suspend it
>continuously from time to time so it won't finish e.g. in 10 minutes but
>in 1 hour.

No you don't. If you have TWO processes which are harming each other
by fighting over memory, you start suspending them alternately: this
makes both complete SOONER than otherwise!

>> With my approach, some processes get suspended, others run to
>> completion freeing up resources for others.
>
>This is black magic also. Why do you think they will run to completion
>or/and free up memory?

If all your active processes are in infinite loops, nothing is going
to help you here short of killing them - which my approach also makes
easier/possible.

>> With this approach, every process will still thrash indefinitely:
>> perhaps the effects on other processes will be reduced, but you
>> don't actually get out of the hole you're in!
>
>So both approach failed.

Note that process suspension already happens, but with too fine a
granularity (the scheduler) - that's what causes the problem. If one
process were able to run uninterrupted for, say, a second, it would
get useful work done, then you could switch to another. The current
scheduling doesn't give enough time for that under thrashing
conditions.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
