Message-ID: <3D28ACAA.1606EC11@opersys.com>
Date: Sun, 07 Jul 2002 17:03:38 -0400
From: Karim Yaghmour <karim@opersys.com>
Reply-To: karim@opersys.com
MIME-Version: 1.0
Subject: Profiling support and system tracing (taken from Re: vm lock contention
 reduction)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, riel@conectiva.com.br, linux-mm@kvack.org, Martin.Bligh@us.ibm.com, Richard Moore <richardj_moore@uk.ibm.com>, bob <bob@watson.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello Linus,

I was forwarded your message on linux-mm regarding enhancing profiling
in Linux (http://mail.nl.linux.org/linux-mm/2002-07/msg00042.html) and
I'd like to point out that some of what you ask for is already part of
the Linux Trace Toolkit.

> I'd like to enhance the profiling support a bit, to create some
> infrastructure for doing different kinds of profiles, not just the current
> timer-based one (and not just for the kernel).

LTT already provides this.

> There's also the P4 native support for "event buffers" or whatever intel
> calls them, that allows profiling at a lower level by interrupting not for
> every event, but only when the hw buffer overflows.
> 
> I haven't had much time to look at the oprofile thing, but what I _have_
> seen has made me rather unhappy (especially the horrid system call
> tracking kludges).

There was a talk at the OLS about Prospect, a profiling tool that uses
oprofile as its collection engine. The speaker acknowledged that they would
have used LTT instead of reimplemeting all the trace points if LTT was
part of the kernel tree.

> I'd rather have some generic hooks (a notion of a "profile buffer" and
> events that cause us to have to synchronize with it, like process
> switches, mmap/munmap - oprofile wants these too), and some generic helper
> routines for profiling (turn any eip into a "dentry + offset" pair
> together with ways to tag specific dentries as being "worthy" of
> profiling).

LTT provides much of this and can easily be extended to include any
additional hooks you would like. Given the way LTT is architectured,
its data can be used by any tool interested in profiling the system
without having to use the user-space tools provided with the LTT package.

There was an in-depth discussion about tracing and hooking in the Linux
kernel as part of the RAS (Reliability, Availability and Serviceability)
bof at the OLS. The attendees, which included the IBM RAS team, agreed to
standardize on LTT and enhance it to include the best features found in
all the other tracing tools already in existence for other OSes. One such
feature which will be added is lockless event logging.

One suggestion I made during some of these discussions is to log hardware
counters when an event occurs. Using this, for example, a developer can
easily pinpoint the number of cache misses caused by his application's call
to write().

There already is an LTT patch ready for 2.5 which I sent to the LKML a
couple of weeks ago. I think its inclusion would really help many
folks out there who end up reimplementing what we've already implemented
and have refined to be as non-intrusive as possible. Plus, LTT has
already been ported to 6 architectures: i386, PowerPC, S/390, SuperH,
MIPS, and ARM. Additional ports are relatively easy to implement.

I would be interested to know what you think about LTT's inclusion in
2.5.

Karim

===================================================
                 Karim Yaghmour
               karim@opersys.com
      Embedded and Real-Time Linux Expert
===================================================
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
