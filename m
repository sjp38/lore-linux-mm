Received: from localhost (haih@localhost [127.0.0.1])
	by azure.engin.umich.edu (8.9.3/8.9.1) with ESMTP id LAA08276
	for <linux-mm@kvack.org>; Wed, 14 Aug 2002 11:58:47 -0400 (EDT)
Date: Wed, 14 Aug 2002 11:58:47 -0400 (EDT)
From: Hai Huang <haih@engin.umich.edu>
Subject: need help with understanding memory usage by a process
Message-ID: <Pine.SOL.4.33.0208141136550.1292-100000@azure.engin.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm fairly new at linux kernel develpment.  First let me describe what
I can gather from my understanding before I post my question.

A Linux process can use memory in many differnt ways:
  1) code section
  2) data section
  3) bss section
  4) heap section
  5) stack section
where each one is described by one vm_area_struct, with the exception of
data section and bss section which is usually concatenated.

Other than these, there are couple other ways a Linux process can consume
memory:
  6) meta data used by the kernel to keep states about the process
     (e.g., struct task, struct mm, struct fs, page tables, etc.)
  7) memory mapped files
  8) shared libraries

I'm not very familiar with the IPC stuff, but I think process also use
memory for
  9) shm IPC

So, the above are the possible source of memory usage of a Linux process
I can think of, but please add if you can think of other possible sources.

Here is what I want to accomplish - for a particular process, I want to
keep all memory footprint (item 1-9, maybe not 8) of this process within
certain physical memory range (assuming I modifies the slab cache and
buddy system a bit which would allow me to do so).  A process is created
by do_fork() and followed by do_execve() (is this right or is there other
path).  So, here is my question (finally :), after do_execve(), and before
this task is first scheduled, the only memory footprint of this process is
from item (6) and nothing else, is this correct?

Thanks for any addendum/suggestion you can provide.

-
Hai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
