Received: from d23rh901.au.ibm.com (d23rh901.au.ibm.com [9.185.167.100])
	by ausmtp01.au.ibm.com (8.12.1/8.12.1) with ESMTP id g8A7XThh323122
	for <linux-mm@kvack.org>; Tue, 10 Sep 2002 17:33:29 +1000
Received: from d23m0067.in.ibm.com (d23m0067.in.ibm.com [9.184.199.180])
	by d23rh901.au.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id g8A7brAW042848
	for <linux-mm@kvack.org>; Tue, 10 Sep 2002 17:37:54 +1000
Subject: Re: oom_killer - Does not perform when stress-tested (system hangs)
Message-ID: <OF4556A3DE.CC39A8B4-ON65256C30.00293E54@in.ibm.com>
From: "Srikrishnan Sundararajan" <srikrishnan@in.ibm.com>
Date: Tue, 10 Sep 2002 13:05:06 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here are a few issues and questions regarding oom_kill.

When there are lots of user processes each mallocing 1 MB and sleeping
forever without freeing, there is a possibility of oom_kill to kill a
critical system task or other processes run as root as long as such a
process qualifies with the highest "badness" value. While the algorithm
does reduce the score for any root process, it does not preclude the
selection of such a process for killing.
I tried to prevent non-root processes from occupying large amounts of
virtual memory by setting ulimit for virtual memory. When I go beyond this,
the user program fails with an a cannot allocate memory error. But this
limit does not take the actual current status into account. ie. Limit is
not say 95% of total memory etc.
I understand that we can allocate quota for hard disk space, there by
preventing non-root processes from occupying any more disk space beyond the
quota limit. For example,  we can set quota such that when the
hard-disk-space is 95% full, only root can occupy further space. Is there a
similar way to enforce the same for memory usage. This might ensure that
errant non-root processes cannot keep on allocating memory, thereby can
prevent the swap from getting full.
Another thought is can we exclude root processes from  the "badness"
calculation. This might ensure that at no time a root process is killed by
oom_kill. Or we can modify this such that as long as a non-root process is
there, no root processes will be killed by oom_kill.

Also the current oom_kill does not seem to always identify the offending
process and kill that.  Is there any way of either identifying a specific
offending process or identify such a user and kill all his processes?


Srikrishnan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
