Message-ID: <20030209043937.7134.qmail@web21309.mail.yahoo.com>
Date: Sat, 8 Feb 2003 20:39:37 -0800 (PST)
From: sandeep uttamchandani <sm_uttamchandani@yahoo.com>
Subject: vmalloc errors in 2.4.20
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The linux kernel 2.4.20 seems to have problems with
vmalloc. Here is what I did:

In my driver, I try to allocate a buffer of size 512K
using vmalloc ( kmalloc cannot allocate more than
128K). It generates a kernel oops message saying that
the virtual memory cannot be allocated.

I suspect there is a problem with the address range
defined for vmalloc namely by VMALLOC_START and
VMALLOC_END. 

Any thoughts of what might be going-on ? 

Please do let me know if you want to look at the
kernel oops message. 

Thanks,
Sandeep
sandeepu@us.ibm.com

__________________________________________________
Do you Yahoo!?
Yahoo! Mail Plus - Powerful. Affordable. Sign up now.
http://mailplus.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
