Date: Tue, 23 Oct 2001 15:07:31 -0500
From: Duffey <email@davidduffey.com>
Subject: Removing pages from the MM
Message-ID: <20011023150731.A20191@dduffey.davidduffey.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear Linux Kernel Memory Hackers,

I am an undergraduate at K-State University majoring in Computer Science.
I have chosen to do an honors research project that involves the memory
manager of Linux.  At the moment I am gathering information to give a
detailed design specification (project feasibility study) for eventual
implementation.

I've been lurking on the mailing list for a month now and have been
impressed with the level of cooperation and technical discussion.
I have experience writing kernel modules for SCSI, block devices, and
networking, but this will be the first time I will be involved with
the MM.  Several message-threads have given me insight into the Linux
kernel MM that you can't find anywhere else.  I hope that my ideas will
do the same.

I want to create a way for users to temporarily free the memory resources
held by their processes and later inject the memory back into the system.
I feel that it is possible to do this without giving the user more
privileges, using different libraries, or recompiling their programs.
It should also be easy to set up (i.e., does not require kernel patching,
or setting up a distributed environment).  In a nutshell, it should be
easy to install and use.

My initial thought is to create a Linux module that provides access to
a process's page table through the /proc filesystem.  If I want to free
the resource held by my process, I would suspend the process first and
then ask for the pages from /proc (i.e., cat /proc/dswap/pid > file).
That would free all the process's pages with exception to locked or
shared memory.  If the user then continues execution at that point,
the process would most likely page fault and die.  On the other hand,
if the user injects the resources back into the process (with cat
file > /proc/dswap/pid) and then continues execution, it would act as if
the process had simply been suspended with the advantage of releasing
memory resources.

I'm interested in previous work and finding others who have done similar
projects or have insight/interest in my project.  I would appreciate
any sources of information that may be related.  I have a couple of
technical questions at the moment.

* Will it be too difficult to access needed areas of the MM from a module?
  Will a patched kernel be necessary?

* After reading through the pagefile code, specifically swapoff, I'm
  concerned about the performance issues of injecting memory back into
  the system.	Will I run into the same problem?  Could injecting memory
  be done in a more efficient manner?

* Will the current changes occurring in the virtual machine dramatically
  affect my code?

My project could also be used to modify a running process.  It could be
used to change simple data structures or even code of a running process,
although, I can't think of a reason anyone would want to do this.  I plan
on making a simple demonstration of this, but I would appreciate a more
practical example.

I would enjoy any of your thoughts, the project specification draft is
due by November 15th.  You can contact me by email, dduffey@cis.ksu.edu,
or by phone 785-565-1589.  Also, Let me know if you would like me to
keep you informed of my progress.  Thank you.

Sincerely,

-- 
David Duffey <email@DavidDuffey.com>                  1605 Hillcrest Dr Apt X30
             -----------------------                  Manhattan, KS 66502
                                                      (785)395-2630
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
