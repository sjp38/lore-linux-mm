Date: Wed, 11 Apr 2007 07:24:12 +0100 (BST)
From: sameer sameer <sameerchakravarthy@yahoo.com>
Subject: question on mmap
In-Reply-To: <Pine.LNX.4.64.0704101715050.3850@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Message-ID: <835465.82854.qm@web43140.mail.sp1.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

I have a question regarding the implementation of
mmap. I am trying to find out if we the kernel
actually shares the memory across unrelated processes
using MAP_SHARED flag for a read only file mapping. 

When the file is mapped with PROT_READ arguement, then
will there be any difference in memory usage by
multiple processes if the mapping is done using
MAP_SHARED instead of MAP_PRIVATE ?

Are there any system commands which will let me know
how to calcuate the memory savings (if there are any)
?

Please let me know. 

Thanks,
Sameer


      Send a FREE SMS to your friend's mobile from Yahoo! Messenger. Get it now at http://in.messenger.yahoo.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
