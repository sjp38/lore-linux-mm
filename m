Received: from ds02c00.directory.ray.com (ds02c00.rsc.raytheon.com [147.25.138.118])
	by dfw-gate4.raytheon.com (8.11.0.Beta3/8.11.0.Beta3) with ESMTP id f0MFt1Z15362
	for <linux-mm@kvack.org>; Mon, 22 Jan 2001 09:55:01 -0600 (CST)
Received: from rtshou-ds01.hou.us.ray.com (localhost [127.0.0.1])
	by ds02c00.directory.ray.com (8.9.3/8.9.3) with ESMTP id JAA10757
	for <linux-mm@kvack.org>; Mon, 22 Jan 2001 09:54:15 -0600 (CST)
Subject: Locked memory questions
Message-ID: <OF55A69DFC.F1913EBB-ON862569DC.00556518@hou.us.ray.com>
From: Mark_H_Johnson@Raytheon.com
Date: Mon, 22 Jan 2001 09:54:49 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Stanley_R_Allen-NR@Raytheon.com
List-ID: <linux-mm.kvack.org>

I was surprised by a reference in the latest kernel traffic
(http://kt.linuxcare.com/kernel-traffic/latest.epl) to a VM problem with
large locked memory regions. I read linux-mm on a daily basis, but didn't
see this particular discussion go by. We're looking at deploying a large
real time system [hard deadlines, lots of locked memory] and have a few
questions based on that discussion...
 [1] Other than the kernel limit on the amount of locked memory [was 50% in
2.2.x], what should I be aware of when setting up a system with huge
amounts of locked memory [say, 75% locked on a 256 to 512 Mbyte machine]?
 [2] Does it matter that I have several threads that map that memory [from
10 to 50, varies by system]?
 [3] Does it matter that the target system is a Pentium III or not?
 [4] Are there any other "known problems" with Linux VM and locked memory?
If so, any idea on when they will be fixed? We're looking to go into system
testing this summer with delivery in November.
 [5] Are the algorithms you are considering for fixing page aging, etc. do
well with locked memory?
 [6] Where does it explain when a locked page is put into memory? I had
assumed it was done when the mlockall() call was done, but now I'm not so
sure. We could put a small hunk of code to walk the address space if
needed, but need to know for sure.
 [7] If I use mlockall(), does it lock the maximum stack size for the
thread its called from [or just the current stack extent]?
 [8] Please confirm - A process with its address space locked is NOT a
candidate for swapping.

In many ways, I'd like the kernel to ignore the locked memory regions from
its analysis for page aging, candidates for swapping, etc. We want to use
most of the CPU cycles to run our application, not manage the memory that
isn't going anywhere.

Thanks.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
