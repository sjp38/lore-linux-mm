From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
Date: Tue, 17 Apr 2001 22:09:05 +0100
Message-ID: <c5cpdt0j8i513ulhnq2gnt8fnjs9hhrmkf@4ax.com>
References: <Pine.LNX.4.21.0104171650530.14442-100000@imladris.rielhome.conectiva> <l03130301b701fc801a61@[192.168.239.105]> <Pine.LNX.4.21.0104171650530.14442-100000@imladris.rielhome.conectiva> <0japdtkjmd12nfj5nplvb4m7n8otq3f8po@4ax.com> <l03130300b7025e809048@[192.168.239.105]>
In-Reply-To: <l03130300b7025e809048@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2001 21:59:46 +0100, you wrote:

>>>> I've got an even better idea.  Monitor each process's "working set" -
>>>> ie. the set of unique pages it regularly "uses" or pages in over some
>>>> period of (real) time.  In the event of thrashing, processes should be
>>>> reserved an amount of physical RAM equal to their working set, except
>>>> for processes which have "unreasonably large" working sets.
>>>
>>>This may be a nice idea to move the thrashing point out a bit
>>>further, and as such may be nice in addition to the load control
>>>code.
>>
>>Yes - in addition to, not instead of. Ultimately, there are workloads
>>which CANNOT be handled without suspending/killing some tasks...
>
>Umm.  Actually, my idea wasn't to move the thrashing point but to limit
>thrashing to processes which (by some measure) deserve it.  Thus the
>thrashing in itself becomes load control, rather than (as at present)
>bringing the entire system down.  Hope that's a bit clearer?

The trouble is, you're effectively suspending these processes, but
wasting system resources on them! It's much more efficient to suspend
then until they can be run properly. If they are genuinely thrashing -
effectively busy-waiting for resources to be available - what point is
there in NOT suspending them?


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
