Subject: Re: MM performance benchmark
References: <3AF71B81.F60D2904@nmu.edu>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 09 May 2001 08:20:23 -0600
In-Reply-To: Randy Appleton's message of "Mon, 07 May 2001 18:02:41 -0400"
Message-ID: <m1oft2li3c.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Appleton <rappleto@nmu.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Randy Appleton <rappleto@nmu.edu> writes:

> Hi!
> 
> I'm a professor of computer science at Northern Michigan University.
> Three students and myself
> have been benchmarking the Linux kernel.  At
> http://euclid.nmu.edu/~benchmark you will see
> graphs describing performance for mmap() and page faults.
> 
> Both graphs show a huge improvement between 2.2 and 2.3.  We see a 100x
> performance
> gain.  My questions is ... Why has performance improved so much?  What
> changed between
> 2.2 and 2.3 to account for a 100x performance improvement?

The page cache usage was rewritten to be threaded, and more
importantly to not double buffer data between the page cache and the
buffer cache.  

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
