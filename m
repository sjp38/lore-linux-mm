From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
Date: Tue, 17 Apr 2001 21:44:23 +0100
Message-ID: <0japdtkjmd12nfj5nplvb4m7n8otq3f8po@4ax.com>
References: <l03130301b701fc801a61@[192.168.239.105]> <Pine.LNX.4.21.0104171650530.14442-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.21.0104171650530.14442-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jonathan Morton <chromi@cyberspace.org>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2001 16:53:51 -0300 (BRST), you wrote:

>On Tue, 17 Apr 2001, Jonathan Morton wrote:
>
>> >It's a very black art, this; "clever" page replacement algorithms will
>> >probably go some way towards helping, but there will always be a point
>> >when you really are thrashing - at which point, I think the best
>> >solution is to suspend processes alternately until the problem is
>> >resolved.
>> 
>> I've got an even better idea.  Monitor each process's "working set" -
>> ie. the set of unique pages it regularly "uses" or pages in over some
>> period of (real) time.  In the event of thrashing, processes should be
>> reserved an amount of physical RAM equal to their working set, except
>> for processes which have "unreasonably large" working sets.
>
>This may be a nice idea to move the thrashing point out a bit
>further, and as such may be nice in addition to the load control
>code.

Yes - in addition to, not instead of. Ultimately, there are workloads
which CANNOT be handled without suspending/killing some tasks...

>> It is still possible, mostly on small systems, to have *every* active
>> process thrashing in this manner.  However, I would submit that if it
>> gets this far, the system can safely be considered overloaded.  :)
>
>... And when the system _is_ overloaded, load control (ie. process
>suspension) is what saves us. Load control makes sure the processes
>in the system can all still make progress and the system can (slowly)
>work itself out of the overloaded situation.

Indeed: the whole problem is that under very heavy load, processes
simply cannot make progress - they will continue to thrash
indefinitely, and the only way out is to suspend or kill one or more
of the offending processes! Clever techniques to make that scenario
less likely to occur in the first place are nice, but we DO need an
"ultimate failsafe" here...


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
