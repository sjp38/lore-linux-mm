Received: from ds02c00.rsc.raytheon.com (ds02c00.rsc.raytheon.com [147.25.138.118])
	by dfw-gate1.raytheon.com (8.9.3/8.9.3) with ESMTP id JAA05712
	for <linux-mm@kvack.org>; Fri, 21 Apr 2000 09:16:16 -0500 (CDT)
From: Mark_H_Johnson@Raytheon.com
Received: from rtshou-ds01.hso.link.com (rtshou-ds01.hso.link.com [130.210.151.8])
	by ds02c00.rsc.raytheon.com (8.9.3/8.9.3) with ESMTP id JAA09646
	for <linux-mm@kvack.org>; Fri, 21 Apr 2000 09:15:52 -0500 (CDT)
Subject: Query on ulimit
Message-ID: <OFB4641C99.2DC226BF-ON862568C8.004B95BB@hso.link.com>
Date: Fri, 21 Apr 2000 09:15:40 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The behavior of resource limits (e.g., "ulimit" in bash) is somewhat
confusing - I think I understand what's happening behind the scenes & I'd
like to confirm what I've found and ask a few questions.

You can use ulimit in bash [or its companion call setrlimit] to view or set
resource limits. For memory related limits, the command ulimit -dsmv on
Linux 2.2.10 shows something like...
data seg size (kbytes)    unlimited
max memory size (kbytes)  unlimited
stack size (kbytes)       8192
virtual memory (kbytes)   unlimited

Attempting to set the virtual memory limit "ulimit -v 48192" always fails,
even with root privilege. The error message appears to be misleading - it
is:
  ulimit: cannot raise limit: Invalid argument
>From what I can tell, the "Invalid argument" is correct, the reason "cannot
raise limit" is incorrect - its that the virtual memory limit is read only
[RIGHT?].

Setting the data seg limit "ulimit -d 40000" succeeds. And the settings now
change to...
data seg size (kbytes)    40000
max memory size (kbytes)  unlimited
stack size (kbytes)       8192
virtual memory (kbytes)   48192

So, to do what I wanted with setting -v, I should use -d instead [RIGHT?].

The best I can tell, setting "ulimit -m 8192" succeeds and you can view the
result, but is not effective at limiting physical memory usage [RIGHT?].

Are there plans for implementing the physical memory limit? If so, when can
I expect it to be done?

In reading various system administrative guides, I can set the hard & soft
limits with the startup files for each shell (e.g., .bashrc or .profile).
However, that requires some "cooperation" from the users since there are a
few ways to avoid execution of those files (e.g., bash -norc -noprofile).
Is there some way to set hard and soft resource limits on a global or per
user basis w/o modifying either the code in the kernel or login?
Thanks.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
