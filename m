Message-ID: <20040310111919.83754.qmail@web10901.mail.yahoo.com>
Date: Wed, 10 Mar 2004 03:19:19 -0800 (PST)
From: Ashwin Rao <ashwin_s_rao@yahoo.com>
Subject: inconsistent do_gettimeofday for copy_page
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For calculating the time required to copy_page i tried
the do_gettimeofday for 1000 pages in a loop. But as
the number of pages changes the time required varies
non-linearly.
I also tried reading xtime and using monotonic_clock
but they didnt help either. For do_gettimeof day for a
single invocation of copy_page on a pentium 4 gave me
10 microsecs but when invoked for a 1000 pages the
time required was 750ns per page.
Is there some way of finding out the exact time
required for copying a page.

Ashwin

__________________________________
Do you Yahoo!?
Yahoo! Search - Find what you?re looking for faster
http://search.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
