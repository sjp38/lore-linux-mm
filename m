Date: Tue, 1 May 2001 13:09:52 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: About reading /proc/*/mem
In-Reply-To: <3AEEEA09.7000301@link.com>
Message-ID: <Pine.GSO.4.21.0105011300110.9771-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard F Weber <rfweber@link.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 1 May 2001, Richard F Weber wrote:

> See this is where I start seeming to have problems.  I can open 
> /proc/*/mem & lseek, but reads come back as "No such process".  However, 
> if I first do a ptrace(PTRACE_ATTACH), then I can read the data, but the 
> process stops.  I've kind of dug through the sys_ptrace() code under 
> /usr/src/linux/arch/i386/kernel/ptrace.c, and can see and understand 
> generally what it's doing, but that's getting into serious kernel-land 
> stuff.  I wouldn't expect it to be this difficult to just open up 
> another processes /proc/*/mem file to read data from.
 
> Is there something obvious I'm missing?  It seems to keep pointing back 
> to ptrace & /proc/*/mem are very closely related (ie: the same) 
> including stopping of the child.

OK, here's something I really don't understand. Suppose that I tell your
debugger to tell me when in the executed program foo becomes greater than
bar[0] + 14. Or when cyclic list foo becomes longer than 1 element
(i.e. foo.next != foo.prev).

How do you do that if program is running? If you don't guarantee that
it doesn't run during the access to its memory (moreover, between sever
such accesses) - the data you get is worthless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
