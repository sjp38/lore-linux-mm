Message-ID: <20021117070320.75710.qmail@web12305.mail.yahoo.com>
Date: Sat, 16 Nov 2002 23:03:20 -0800 (PST)
From: Ravi <kravi26@yahoo.com>
Subject: Page size andFS blocksize
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
 I was browsing the block device read/write code in fs/buffer.c (kernel
version 2.4.18).
>From waht I understood,  there is an implicit assumption that
filesystem block sizes
are never more than the size of a single page. I say this because I
couldn't figure
out how to specify if the page being read is part of a block. (The
buffer_head structure
has no member that says 'offset within the block').  
  Have I read the code right, or am I missing something? And has this
changed in
2.5?

-Thanks,
 Ravi.

__________________________________________________
Do you Yahoo!?
Yahoo! Web Hosting - Let the expert host your site
http://webhosting.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
