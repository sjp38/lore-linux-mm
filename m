Date: Wed, 4 Sep 2002 11:48:04 -0400
From: Adam Kropelin <akropel1@rochester.rr.com>
Subject: Re: 2.5.33-mm2
Message-ID: <20020904154804.GA29967@www.kroptech.com>
References: <3D75CD24.AF9B769B@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D75CD24.AF9B769B@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Seems to need this patch to satisfy the compiler gremlins...

--Adam

--- linux-2.5.33-mm2.orig/mm/vmalloc.c	Wed Sep  4 11:42:50 2002
+++ linux-2.5.33-mm2/mm/vmalloc.c	Wed Sep  4 11:38:53 2002
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
+#include <linux/interrupt.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
