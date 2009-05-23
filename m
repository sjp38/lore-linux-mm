Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4A89A6B004F
	for <linux-mm@kvack.org>; Sat, 23 May 2009 00:46:40 -0400 (EDT)
Date: Fri, 22 May 2009 21:43:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bugme-new] [Bug 13366] New: About 80% of shutdowns fail
 (blocking)
Message-Id: <20090522214305.8e2d474a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, mrb74@gmx.at
List-ID: <linux-mm.kvack.org>


Guys, I'm still in Australia and won't be much use until next week.  We
have a post-2.6.29 regression here, something to do with mlockall() and its
cross-CPU LRU draining.  Could someone please take a look?

Thanks.


Begin forwarded message:

Date: Sat, 23 May 2009 00:58:25 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 13366] New: About 80% of shutdowns fail (blocking)


http://bugzilla.kernel.org/show_bug.cgi?id=13366

           Summary: About 80% of shutdowns fail (blocking)
           Product: Process Management
           Version: 2.5
    Kernel Version: 2.6.30-rc6+latest git patches
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
        AssignedTo: process_other@kernel-bugs.osdl.org
        ReportedBy: mrb74@gmx.at
        Regression: Yes


Created an attachment (id=21499)
 --> (http://bugzilla.kernel.org/attachment.cgi?id=21499)
Screenshot of kernel crash output.

When the system shuts down/reboots nearly every shutdown stops when trying to
kill all processes with killall5. Pressing the power button has no effect in
most cases. Only the magic key sequences work.
This problem occures since 2.6.30-rc6. 2.6.30-rc5 had no problems with shutting
down/rebooting.

-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are on the CC list for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
