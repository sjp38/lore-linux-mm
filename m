Received: from deliverator.sgi.com (deliverator.sgi.com [204.94.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA21094
	for <linux-mm@kvack.org>; Mon, 31 May 1999 15:39:45 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905311939.MAA77710@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm4.0-2.2.9 Free up VM_GROWSUP for new use
Date: Mon, 31 May 1999 12:39:27 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

It seems to me that the flag bit VM_GROWSUP is not set anywhere.
Seeing that the vm_flags bits are nearly all taken, it is probably
worthwhile to free up this bit for new usage. Here's the patch to
do that.

Thanks.

Kanoj
kanoj@engr.sgi.com


--- arch/mips/kernel/irixelf.c	Mon May 31 12:21:02 1999
+++ irixelf.c1	Mon May 31 12:22:16 1999
@@ -1050,7 +1050,7 @@
 	if (!(vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC)))
 		return 0;
 #if 1
-	if (vma->vm_flags & (VM_WRITE|VM_GROWSUP|VM_GROWSDOWN))
+	if (vma->vm_flags & (VM_WRITE|VM_GROWSDOWN))
 		return 1;
 	if (vma->vm_flags & (VM_READ|VM_EXEC|VM_EXECUTABLE|VM_SHARED))
 		return 0;
--- fs/binfmt_elf.c	Mon May 31 12:20:57 1999
+++ binfmt_elf.c1	Mon May 31 12:22:02 1999
@@ -960,7 +960,7 @@
 	if(vma->vm_flags & VM_IO)
 		return 0;
 #if 1
-	if (vma->vm_flags & (VM_WRITE|VM_GROWSUP|VM_GROWSDOWN))
+	if (vma->vm_flags & (VM_WRITE|VM_GROWSDOWN))
 		return 1;
 	if (vma->vm_flags & (VM_READ|VM_EXEC|VM_EXECUTABLE|VM_SHARED))
 		return 0;
--- mm.h	Mon May 31 12:20:50 1999
+++ mm.h1	Mon May 31 12:26:08 1999
@@ -73,7 +73,7 @@
 #define VM_MAYSHARE	0x0080
 
 #define VM_GROWSDOWN	0x0100	/* general info on the segment */
-#define VM_GROWSUP	0x0200
+#define VM_notused	0x0200	/* this flagbit free for any use */
 #define VM_SHM		0x0400	/* shared memory area, don't swap out */
 #define VM_DENYWRITE	0x0800	/* ETXTBSY on write attempts.. */
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
