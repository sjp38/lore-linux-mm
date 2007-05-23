Date: Tue, 22 May 2007 17:42:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Sparsemem Virtual Memmap V4
In-Reply-To: <exportbomb.1179873917@pinky>
Message-ID: <Pine.LNX.4.64.0705221730420.19465@schroedinger.engr.sgi.com>
References: <exportbomb.1179873917@pinky>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

We will need this fix to sparsemem on IA64. I hope this will not cause 
other issues in sparsemem?


IA64: Increase maximum physmem size to cover 8 petabyte

We currently can support these large configurations only with Discontigmem.

Increase sparsemems max physmem bits to also be able to handle 8 petabyte.

Discontigmem supports up to 16 petabyte but I will need to use bit 53 to 
flag vmemmap addresses for the TLB handler. It seems that the currently 
used bit 60 for the 16M configuration is not supported by a certain 
virtualization technique.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc2/include/asm-ia64/sparsemem.h
===================================================================
--- linux-2.6.22-rc2.orig/include/asm-ia64/sparsemem.h	2007-05-22 17:28:04.000000000 -0700
+++ linux-2.6.22-rc2/include/asm-ia64/sparsemem.h	2007-05-22 17:28:37.000000000 -0700
@@ -8,7 +8,7 @@
  */
 
 #define SECTION_SIZE_BITS	(30)
-#define MAX_PHYSMEM_BITS	(50)
+#define MAX_PHYSMEM_BITS	(53)
 #ifdef CONFIG_FORCE_MAX_ZONEORDER
 #if ((CONFIG_FORCE_MAX_ZONEORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS)
 #undef SECTION_SIZE_BITS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
