From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Thu, 19 Apr 2001 10:15:22 +0100
Message-ID: <lsatdtg66634aevabc8g6o8fck67t01kkv@4ax.com>
References: <0jurdtceqe39l7019vhckcgktk42m7bln1@4ax.com> <Pine.LNX.4.30.0104190031190.20939-100000@fs131-224.f-secure.com>
In-Reply-To: <Pine.LNX.4.30.0104190031190.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001 01:25:46 +0200 (MET DST), you wrote:

>On Wed, 18 Apr 2001, James A. Sutherland wrote:
>> >How you want to avoid "deadlocks" when running processes have
>> >dependencies on suspended processes?
>> If a process blocks waiting for another, the thrashing will be
>> resolved.
>
>This is a big simplification, e.g. not if it polls [not poll(2)].

If it is just polling waiting for something - i.e. check for result
file, sleep, repeat - then it isn't part of the thrashing workload.

>> They will get this feedback, and more effectively than they do now:
>> right now, they are left with a dead box they have to reboot. With
>
>Not if they RTFM. Moreover thrashing != dead.

Thrashing == dead == hard reboot needed. If you cannot log in as root
to kill the offending processes, and the processes in question are
thrashing, you are unlikely to recover the system on a practical
timescale.

>> IF you overload the system to extremes, then your processes will stop
>> running for brief periods. Right now, they ALL stop running
>> indefinitely!
>
>This is not true. There *is* progress, it just can be painful slow.

Not necessarily: it can easily go into a hard loop to the point you
never recover without rebooting.

>> You haven't thought it through, then.
>
>"If you don't learn from history .... ". Anyway get familiar with AIX.

OK, how does AIX handle the system effectively locking up?

>But as I wrote before, I can't see problem with optional implementation
>even I think the whole issue is a user space one and kernel efforts
>should be concentrated fixing 2.4 MM bugs.

The issue can't really be solved properly in userspace... Once
thrashing has started, your userspace daemon may not necessarily ever
get swapped in enough to run! If you mlock the whole thing and are
very careful, you might just be able to SIGSTOP suitable processes -
but why not just do this kernel-side, where it should be much easier?


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
