From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Sun, 22 Apr 2001 11:19:07 +0100
Message-ID: <0tb5et46n2bqpos4qnhmqjvc5ni1vusv49@4ax.com>
References: <11530000.987705299@baldur> <Pine.LNX.4.30.0104201223390.20939-100000@fs131-224.f-secure.com>
In-Reply-To: <Pine.LNX.4.30.0104201223390.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Dave McCracken <dmc@austin.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2001 14:18:34 +0200 (MET DST), you wrote:

>On Thu, 19 Apr 2001, Dave McCracken wrote:
>> --On Wednesday, April 18, 2001 23:32:25 +0200 Szabolcs Szakacsits
>> > How you want to avoid "deadlocks" when running processes have
>> > dependencies on suspended processes?
>> I think there's a semantic misunderstanding here.  If I understand Rik's
>> proposal right, he's not talking about completely suspending a process ala
>> SIGSTOP.  He's talking about removing it from the run queue for some small
>> length of time (ie a few seconds, probably) during which all the other
>> processes can make progress.
>
>Yes, I also didn't mean deadlocks in its classical sense this is the
>reason I put it in quote. The issue is the unexpected potentially huge
>communication latencies between processes/threads or between user and
>system. App developers do write code taking load/latency into account
>but not in mind some of their processes/threads can get suspended for
>indeterminated interval from time to time.

If some part of the multi-threaded/multi-process system overloads the
system to the point of thrashing, it has already failed, and is likely
to encounter a SIGKILL from the sysadmin - if and when the sysadmin is
able to issue a SIGKILL...

>> This kind of suspension won't be noticeable to users/administrators
>> or permanently block dependent processes.  In fact, it should make
>> the system appear more responsive than one in a thrashing state.
>
>With occasionally suspended X, sshd, etc, etc, etc ;)

If sshd blows up to the point of getting suspended, it's already gone
wrong... Suspending X could happen, and would be a *GOOD* thing under
the circumstances: it would then enable you to kill the rogue
process(es) on a virtual console or network login.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
