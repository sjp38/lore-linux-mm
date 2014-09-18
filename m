Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 769086B0035
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 15:56:26 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so1060133pdi.30
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 12:56:26 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id iv3si41459962pbd.30.2014.09.18.12.56.22
        for <linux-mm@kvack.org>;
        Thu, 18 Sep 2014 12:56:23 -0700 (PDT)
Subject: [PATCH] [v2] x86: update memory map about hypervisor-reserved area
From: Dave Hansen <dave@sr71.net>
Date: Thu, 18 Sep 2014 12:56:06 -0700
Message-Id: <20140918195606.841389D2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, ryabinin.a.a@gmail.com, dvyukov@google.com, andi@firstfloor.org, x86@kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com


changes from v1:
 * fix the actual address since the reserved area is larger than
   the guard hole

--

From: Dave Hansen <dave.hansen@linux.intel.com>

Peter Anvin says:
> 0xffff880000000000 is the lowest usable address because we have
> agreed to leave 0xffff800000000000-0xffff880000000000 for the
> hypervisor or other non-OS uses.

Let's call this out in the documentation.

This came up during the kernel address sanitizer discussions
where it was proposed to use this area for other kernel things.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
---

 b/Documentation/x86/x86_64/mm.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN Documentation/x86/x86_64/mm.txt~update-x86-mm-doc Documentation/x86/x86_64/mm.txt
--- a/Documentation/x86/x86_64/mm.txt~update-x86-mm-doc	2014-09-18 12:43:55.672230059 -0700
+++ b/Documentation/x86/x86_64/mm.txt	2014-09-18 12:55:17.642795338 -0700
@@ -5,7 +5,7 @@ Virtual memory map with 4 level page tab
 
 0000000000000000 - 00007fffffffffff (=47 bits) user space, different per mm
 hole caused by [48:63] sign extension
-ffff800000000000 - ffff80ffffffffff (=40 bits) guard hole
+ffff800000000000 - ffff87ffffffffff (=43 bits) guard hole, reserved for hypervisor
 ffff880000000000 - ffffc7ffffffffff (=64 TB) direct mapping of all phys. memory
 ffffc80000000000 - ffffc8ffffffffff (=40 bits) hole
 ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
