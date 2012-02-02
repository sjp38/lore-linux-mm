Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 1F8836B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 08:37:51 -0500 (EST)
Message-ID: <4F2A91AA.5080002@parallels.com>
Date: Thu, 02 Feb 2012 17:37:46 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC][ATTEND] cleancache extension and memory checkpoint/restore
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsc-pc@lists.linux-foundation.org
Cc: Linux MM <linux-mm@kvack.org>

Hi.

I'd like to attend the event to discuss the following topics:


1. cleancache extension

In containerized systems, when containers are more or less equal to each
other, we can save RAM and (!) disk IOPS if we share equal files between
containers. We've been using a unionfs-like approach and faced several 
disadvantages of it (I can describe them in details if required).

Now we're working on extending the cleancache subsystem to achieve this 
sharing. The cost of fully isolated filesystems is very high, I can provide 
numbers of various performance experiments, thus this is required badly for
containers.


2. memory checkpoint/restore

Yet another project I'm working on is CRIU -- checkpoint-restore in userspace.
One of the problems we've met is -- it's impossible to determine a task's 
current working set from the usepspace.

Another problem of the nearest future is the ability to create the memory snapshot
of a running task for more efficient migration and incremental checkpoint.


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
