Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniele Bellucci <bellucda@tiscali.it>
Reply-To: bellucda@tiscali.it
Subject: Re: 2.6.0-test2-mm4
Date: Mon, 4 Aug 2003 13:56:03 +0200
References: <20030804013036.16d9fa3a.akpm@osdl.org>
In-Reply-To: <20030804013036.16d9fa3a.akpm@osdl.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200308041356.03739.bellucda@tiscali.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

make all:

mm/usercopy.c: In function `pin_page':
mm/usercopy.c:55: warning: implicit declaration of function `in_atomic'
mm/built-in.o: In function `rw_vm':
/usr/src/linux-2.6.0-test2-mm4/mm/usercopy.c:55: undefined reference to `in_atomic'
make: *** [.tmp_vmlinux1] Error 1

seems like #include <linux/interrupt.h> is missing.


diff -urN 1.0/mm/usercopy.c 1.1/mm/usercopy.c
--- 1.0/mm/usercopy.c	2003-08-04 13:46:22.000000000 +0200
+++ 1.1/mm/usercopy.c	2003-08-04 13:46:39.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
 #include <linux/ptrace.h>
+#include <linux/interrupt.h>
 
 #include <asm/pgtable.h>
 #include <asm/uaccess.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
