Received: from ds02w00.directory.ray.com (ds02w00.directory.ray.com [147.25.146.118])
	by bos-gate3.raytheon.com (8.11.0.Beta3/8.11.0.Beta3) with ESMTP id f9U0hot28671
	for <linux-mm@kvack.org>; Mon, 29 Oct 2001 19:43:50 -0500 (EST)
Received: from rtshou-ds01.hou.us.ray.com (localhost [127.0.0.1])
	by ds02w00.directory.ray.com (8.9.3/8.9.3) with ESMTP id QAA15666
	for <linux-mm@kvack.org>; Mon, 29 Oct 2001 16:43:48 -0800 (PST)
Subject: Physical address of a user virtual address
Message-ID: <OF59D35C34.54785967-ON86256AF5.0002C7E7@hou.us.ray.com>
From: Mark_H_Johnson@Raytheon.com
Date: Mon, 29 Oct 2001 18:42:51 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: James_P_Cassidy@Raytheon.com
List-ID: <linux-mm.kvack.org>

We have an application where we will be...
 - using mlockall() to lock the application into physical memory
 - communicating to / from other systems using an interface similar to
shared memory
 - most of the other systems run Linux - we have a device driver to handle
that case (they exchange information so the operation is "safe")
 - but one of the other systems does not have an operating system - just
our code

For the system with our code in it, we need the physical address of a
region in the user's virtual address space. We are aware of the problems
with memory fragmentation and would be probing several addresses (at 4
Kbyte boundaries) to compute the base address & lengths of each contiguous
region.

We can't seem to find any "easy" way (e.g., call a function) that converts
an address in the virtual address space of an application to the physical
address. The book "Linux Device Drivers" basically tells us to walk the
page tables. From that, we think we must create a driver or kernel module
to get access to the proper variables and functions. That looks like a lot
of work for something that sounds simple.

Has someone already solved this done this and can point us to some code
that implements this?

Is there a better way to solve this problem?

Thanks.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
