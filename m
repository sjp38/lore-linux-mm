Message-ID: <20030125004421.96940.qmail@web41007.mail.yahoo.com>
Date: Fri, 24 Jan 2003 16:44:21 -0800 (PST)
From: Jason Li <zhjl000@yahoo.com>
Subject: linux free pages on 2.4.19
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Have a simple question:

	When monitoring system's memory usage, I found out
that the physical page numbders used by the
application increases by 3000 pages (4K on ppc), but
the system's free page count shrink only by 70 pages
using the nr_free_pages and 200 pages when counting
the page frames that has 0 reference count.

	1) Does this make sense? 3000 * 4K = 12M and the free
counts doesn't shrink accordingly, it means the kernel
memory is shrinking/cleaned? We don't have swap space
though we have a fs.
	2) Why the the nr_free_pages and the zero reference
count page frame number are so different by 1000 ~
7500. Does this mean a bigger page cache?
	3) what is the best way to find out how much space is
used up user space vs the kernel space?

Thanks in advance for your help.

Regards,
Jason


__________________________________________________
Do you Yahoo!?
Yahoo! Mail Plus - Powerful. Affordable. Sign up now.
http://mailplus.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
