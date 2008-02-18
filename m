Received: by wr-out-0506.google.com with SMTP id 60so1735256wri.8
        for <linux-mm@kvack.org>; Mon, 18 Feb 2008 07:56:00 -0800 (PST)
Message-ID: <e2e108260802180755l1c80b13an89ed417c20132f08@mail.gmail.com>
Date: Mon, 18 Feb 2008 16:55:58 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Synchronization of the procps tools with /proc/meminfo
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, acahalan@cs.uml.edu
List-ID: <linux-mm.kvack.org>

As known the tools in the procps package (e.g. top and free) obtain
their status information from the Linux kernel by reading a.o.
/proc/meminfo. Both top and free report a.o. the following
information:
* Total amount of physical memory.
* Physical memory in use (reclaimable + unreclaimable).
* Unreclaimable physical memory.
Current versions of the procps tools only take "Buffers" and "Cached"
in account as reclaimable memory and ignore the SReclaimable field
(slab reclaimable, includes a.o. the memory occupied by dentry and
inode structures), one of the more recently added /proc/meminfo field
(the latest procps release (version 3.2.7) dates from June 25, 2006).
I would like to see both top and free modified such that these take
the SReclaimable field in account. The reason is that the numbers
reported by free as "-/+ buffers/cache" are useless on recent kernels
when monitoring a Linux system for memory leaks in kernel and/or
server processes. E.g. when findutils updates its database, a lot of
extra dentry and inodes are cached. The output of "free" shows a
significant increase in the amount of memory used, while only
SReclaimable increased and not the unreclaimable physical memory.

This leads me to the question: if the layout of /proc/meminfo changes,
who communicates these changes to the procps maintainers ? And who
maintains the procps package ? I have tried before to contact Albert
Calahan but without success so far.

See also:
* The procps package -- http://procps.sourceforge.net/
* A previous attempt to inform the procps maintainers:
http://sourceforge.net/mailarchive/forum.php?thread_name=e2e108260802132333w4459ae23o3a5930583f426339%40mail.gmail.com&forum_name=procps-feedback

Bart Van Assche.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
