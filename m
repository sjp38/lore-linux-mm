Subject: Re: linux vm page sharing
Message-ID: <OFA2C1FE71.61EAC8D1-ON86256DDA.005005B4@raytheon.com>
From: Mark_H_Johnson@Raytheon.com
Date: Mon, 10 Nov 2003 08:45:42 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sharath Kodi Udupa <sku@CS.Arizona.EDU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




>i am trying to implement a system where different processes can share
>pages, this means that not only same executables, but different
>executables , but when the pages required are same.

Why not use one of the existing memory management functions such as:
 - mmap, munmap to map a file into memory (this also provides persistence)
 - shmget, shmat, shmdt, shmctl to create, attach, detach, and control
shared memory segments. The status of these is also available through the
ipcs command line program. Also look at "man 5 ipc" to get a summary of
interprocess communications methods (semaphores, shared memory, message
queues).
Note that the base address of the memory segments are not necessarily the
same in each executable. This means you should always use offsets (relative
to the base of shared memory) to locate items within the shared memory
area. For example, you code would compute the "real address" as the "base
address" plus "offset" before dereferencing pointers. Trying to force the
base address of the shared memory is "hard" and prone to problems due to
the relative size of the executables.

>[snip - looking at page structure]
I would use just the documented interfaces for shared memory.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
