Date: Sat, 17 Aug 2002 12:09:20 +0100 (IST)
From: Mel <mel@csn.ul.ie>
Subject: Re: VM Regress 0.5 - Compile error with CONFIG_HIGHMEM
In-Reply-To: <Pine.LNX.4.44.0208150312220.20123-100000@skynet>
Message-ID: <Pine.LNX.4.44.0208171206200.7887-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Aug 2002, Mel wrote:

>
> Project page: http://www.csn.ul.ie/~mel/projects/vmregress/
> Download:     http://www.csn.ul.ie/~mel/projects/vmregress/vmregress-0.5.tar.gz

0.5 won't compile with CONFIG_HIGHMEM set. Apply the following trivial
patch and it will compile at least. VM Regress has not been tested with
CONFIG_HIGHMEM set at all but there is no reason for it to fail because no
presumptions has been made about the number of nodes or zones in the
machine


--- vmregress-0.5/src/sense/kvirtual.c	Tue Aug 13 22:43:48 2002
+++ vmregress-0.5-highmem/src/sense/kvirtual.c	Sat Aug 17 12:03:02 2002
@@ -29,6 +29,11 @@
 #include <linux/mm.h>
 #include <linux/sched.h>

+#ifdef CONFIG_HIGHMEM
+#include <linux/highmem.h>
+#include <asm/highmem.h>
+#endif
+
 MODULE_AUTHOR("Mel Gorman <mel@csn.ul.ie>");
 MODULE_DESCRIPTION("Prints out the kernel virtual memory area");
 MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
