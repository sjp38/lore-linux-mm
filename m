Date: Mon, 16 Feb 2004 11:09:27 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Non-GPL export of invalidate_mmap_range
Message-ID: <20040216190927.GA2969@us.ibm.com>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Andrew,

The attached patch to make invalidate_mmap_range() non-GPL exported
seems to have been lost somewhere between 2.6.1-mm4 and 2.6.1-mm5.
It still applies cleanly.  Could you please take it up again?

						Thanx, Paul

------------------------------------------------------------------------



It was EXPORT_SYMBOL_GPL(), however IBM's GPFS is not GPL.

- the GPFS team contributed to the testing and development of
  invaldiate_mmap_range().

- GPFS was developed under AIX and was ported to Linux, and hence meets
  Linus's "some binary modules are OK" exemption.

- The export makes sense: clustering filesystems need it for shootdowns to
  ensure cache coherency.



 25-akpm/mm/memory.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/memory.c~invalidate_mmap_range-non-gpl-export mm/memory.c
--- 25/mm/memory.c~invalidate_mmap_range-non-gpl-export	Mon Nov 24 11:33:19 2003
+++ 25-akpm/mm/memory.c	Mon Nov 24 11:33:34 2003
@@ -1164,7 +1164,7 @@ void invalidate_mmap_range(struct addres
 		invalidate_mmap_range_list(&mapping->i_mmap_shared, hba, hlen);
 	up(&mapping->i_shared_sem);
 }
-EXPORT_SYMBOL_GPL(invalidate_mmap_range);
+EXPORT_SYMBOL(invalidate_mmap_range);
 
 /*
  * Handle all mappings that got truncated by a "truncate()"

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
