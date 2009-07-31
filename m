Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD7FF6B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 16:20:00 -0400 (EDT)
Date: Fri, 31 Jul 2009 13:19:50 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] docs: Remove some very outdated recommendations in
 Documentation/memory.txt
Message-Id: <20090731131950.bf339521.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Any comments on this patch from Andi?

Thanks.

---
From: Andi Kleen <ak@linux.intel.com>

Remove some very outdated recommendations in Documentation/memory.txt

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 Documentation/memory.txt |   31 ++-----------------------------
 1 file changed, 2 insertions(+), 29 deletions(-)

--- linux-2.6.31-rc4-git6.orig/Documentation/memory.txt
+++ linux-2.6.31-rc4-git6/Documentation/memory.txt
@@ -1,18 +1,7 @@
 There are several classic problems related to memory on Linux
 systems.
 
-	1) There are some buggy motherboards which cannot properly 
-	   deal with the memory above 16MB.  Consider exchanging
-	   your motherboard.
-
-	2) You cannot do DMA on the ISA bus to addresses above
-	   16M.  Most device drivers under Linux allow the use
-           of bounce buffers which work around this problem.  Drivers
-	   that don't use bounce buffers will be unstable with
-	   more than 16M installed.  Drivers that use bounce buffers
-	   will be OK, but may have slightly higher overhead.
-	
-	3) There are some motherboards that will not cache above
+	1) There are some motherboards that will not cache above
 	   a certain quantity of memory.  If you have one of these
 	   motherboards, your system will be SLOWER, not faster
 	   as you add more memory.  Consider exchanging your 
@@ -24,7 +13,7 @@ It can also tell Linux to use less memor
 If you use "mem=" on a machine with PCI, consider using "memmap=" to avoid
 physical address space collisions.
 
-See the documentation of your boot loader (LILO, loadlin, etc.) about
+See the documentation of your boot loader (LILO, grub, loadlin, etc.) about
 how to pass options to the kernel.
 
 There are other memory problems which Linux cannot deal with.  Random
@@ -42,19 +31,3 @@ Try:
 	  with the vendor. Consider testing it with memtest86 yourself.
 	
 	* Exchanging your CPU, cache, or motherboard for one that works.
-
-	* Disabling the cache from the BIOS.
-
-	* Try passing the "mem=4M" option to the kernel to limit
-	  Linux to using a very small amount of memory. Use "memmap="-option
-	  together with "mem=" on systems with PCI to avoid physical address
-	  space collisions.
-
-
-Other tricks:
-
-	* Try passing the "no-387" option to the kernel to ignore
-	  a buggy FPU.
-
-	* Try passing the "no-hlt" option to disable the potentially
-          buggy HLT instruction in your CPU.




---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
