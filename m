Message-ID: <38209F51.CCADD7D0@kscable.com>
Date: Wed, 03 Nov 1999 14:47:13 -0600
From: Tom Hull <thull@kscable.com>
Reply-To: thull@kscable.com
MIME-Version: 1.0
Subject: Re: The 64GB memory thing
References: <Pine.LNX.4.10.9911031802330.7408-100000@chiara.csoma.elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> On Wed, 3 Nov 1999, Neil Conway wrote:
> 
> > And presumably each process is still limited to a 32-bit address space,
> > right?
> 
> yes, this is a fundamental limitation of x86 processors. Under Linux -in
> all 3 high memory modes- user-space virtual memory is 3GB. Nevertheless on
> a 8-way box you likely want to run either lots of processes, or a few (but
> more than 8 ) processes/threads to use up all available CPU time. This
> means with 8x 2GB RSS number crunching processes we already cover 16GB
> RAM. So it's not at all unrealistic to have support for more than 4GB RAM!
> The foundation for this is that under Linux all 64GB RAM can be mapped
> into user processes transparently. I believe other x86 unices (not to talk
> about NT) do not have this propertly, they handle 'high memory' as a
> special kind of RAM which can be accessed through special system calls.

SCO UnixWare (as of Release 7.1) has the ability to transparently map
PAE-addressable memory into user processes. A brief history:

Starting with 7.0 (Spring 1998), SCO UnixWare supports PAE mode for accessing
physical memory up to 64GB. In 7.0, such memory (called Dedicated Memory) was
only available for shared memory segments. New system calls (called dshm) were
introduced at that time. The dshm calls are not necessary for a user process
to access high (above 4GB) memory, but without dshm a user process is limited
to its 3GB virtual address space. Dshm provides a window for dynamically
mapping a portion of a much larger shared memory segment into the user's
ddress space.

UnixWare 7.1 (Spring 1999) support for using high memory for all purposes.
The default tuning limits general purpose memory to 8GB, and retains the
concept of Dedicated Memory for memory above the general purpose memory
tune point. The tuning can be adjusted by changing a boot parameter, so
that general purpose memory size can be increased to larger values if the
workload permits. (The example of 8x 2GB RSS number crunchine process is
a relatively painless scenario.)

-- 
/*
 * Tom Hull -- mailto:thull@kscable.com or thull@ocston.org
 *             http://www.ocston.org/~thull/
 */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
