Message-ID: <3F5CADD3.2070404@movaris.com>
Date: Mon, 08 Sep 2003 09:26:59 -0700
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: Differences between VM structs
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kernel Newbies <kernelnewbies@nl.linux.org>, Linux Memory Manager List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all,

I apologize to ask these questions here, but I got no response from the 
newbies list...

     1. Regarding non-contiguous memory allocation, what is the need to 

        have *virtually* contiguous but not *physically* contiguous
        pages?
     2. UtLVMM says that vmalloc is only used in the kernel for storing
        swap information - yet it's used by a bunch of drivers which
        are considered part of the kernel; is it just semantics?
     3. Is vmalloc called from user-mode ever?
     4. Can you state a succint/brief comparison of the difference
        between kmalloc, malloc, and vmalloc with usage examples of each?
     5. Anonymous memory is memory that is *not* backed by a file, such
        as the stack or heap space, right? And mmap is called when
        mapping files into memory, right? The why does mmap deal with
        anonymous memory (sorry, I'm totally confused here)?

TIA!
Kirk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
