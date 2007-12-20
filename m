Received: by wa-out-1112.google.com with SMTP id m33so5064248wag.8
        for <linux-mm@kvack.org>; Thu, 20 Dec 2007 01:23:53 -0800 (PST)
Message-ID: <6934efce0712200123h3482ae17x957d019cc87bf093@mail.gmail.com>
Date: Thu, 20 Dec 2007 01:23:53 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
In-Reply-To: <476924E0.8010304@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476924E0.8010304@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Dec 19, 2007 6:04 AM, Carsten Otte <cotte@de.ibm.com> wrote:
> Nick Piggin wrote:
> > This is just a prototype for one possible way of supporting this. I may
> > be missing some important detail or eg. have missed some requirement of the
> > s390 XIP block device that makes the idea infeasible... comments?
> I've tested your patch series on s390 with dcssblk block device and
> ext2 file system with -o xip. Everything seems to work fine. I will
> now patch my kernel not to build struct page for the shared segment
> and see if that works too.

I tested it with AXFS for ARM on NOR flash (pfn) and with a UML build
on x86 using the UML iomem interface (struct page).  Works slick.
Cleans up the nastiest part of AXFS and makes a MTD patch unnecessary.
 Very nice.

So we've got some documentation to do and you missed this, it won't
compile with EXT2 XIP off.

diff -r e677a09f65e2 fs/ext2/xip.h
--- a/fs/ext2/xip.h     Thu Dec 20 00:53:18 2007 -0800
+++ b/fs/ext2/xip.h     Thu Dec 20 01:14:41 2007 -0800
@@ -21,5 +21,5 @@ void *ext2_get_xip_address(struct addres
 #define ext2_xip_verify_sb(sb)                 do { } while (0)
 #define ext2_use_xip(sb)                       0
 #define ext2_clear_xip_target(inode, chain)    0
-#define ext2_get_xip_page                      NULL
+#define ext2_get_xip_address                   NULL
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
