Date: Fri, 30 May 2003 22:15:04 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: pgcl-2.5.70-bk4-1
Message-ID: <20030531051504.GX15692@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(1) fix for fault_in_page_*() not faulting in enough mmupages.
(2) fix for bogus open-coded ptep_to_address()
(3) fix for iounmap() missing its targets

Unfortunately, none of these are the bug we're looking for.
(which is wrong pages landing on the LRU's)

A pgcl-2.5.70-2 patch with these changes incrementally atop
pgcl-2.5.70-1 is also available.

Available from the usual place:
ftp://ftp.kernel.org/pub/linux/kernel/people/wli/vm/pgcl/


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
