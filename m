From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load
Date: Fri, 20 Apr 2001 07:35:06 +0100
Message-ID: <d3mvdtsi5qivmim4o2uji2ca97017qq71f@4ax.com>
References: <1809062307.20010319210655@dragon.cz> <rnhudtssc00ia2r1unis96lfjd2slb8mup@4ax.com> <m1g0f4rz0v.fsf@frodo.biederman.org>
In-Reply-To: <m1g0f4rz0v.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: happz <happz@dragon.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 19 Apr 2001 22:11:28 -0600, you wrote:

>"James A. Sutherland" <jas88@cam.ac.uk> writes:
>
>> On Mon, 19 Mar 2001 21:06:55 +0100, you wrote:
>> 
>> >What about this: give to process way how to tell kernel "it is not
>> >good to suspend me, because there are process' that depend on me and
>> >wouldn't be blocked." Syscall or /proc filesystem could be used.
>> >
>> >It is not the way how to say which process should be suspended but a
>> >way how to say which could NOT - usefull for example for X server, may
>> >be some daemons, aso.
>> 
>> Possibly; TBH, I don't think it's worth it. Remember, "suspending" X
>> would just stop your mouse moving etc. for (e.g.) 5 seconds; in fact,
>> that should block most graphical processes, which may well resolve the
>> thrashing in itself!
>
>Actually we should only apply suspension and the like to SCHED_OTHER.
>The realtime scheduling classes should be left as is.  If an
>application is safe to run realtime, it should be o.k. in the
>thrashing situation. 
>
>Also actually suspending a realtime process would be a violation of
>the realtime scheduling guarantees, where with SCHED_OTHER you can be
>expected to be suspended at any time.

Yes, I was taking that for granted; apart from anything else, realtime
processes are "supposed to" (according to the manpages, anyway!) be
mlock()ed, which makes suspending them pointless: it won't free any
memory anyway.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
