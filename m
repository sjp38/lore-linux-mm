Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id EAA19869
	for <linux-mm@kvack.org>; Thu, 2 Jan 2003 04:56:53 -0800 (PST)
Message-ID: <3E143714.6C939689@digeo.com>
Date: Thu, 02 Jan 2003 04:56:52 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: 2.5.54-mm2
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.54/2.5.54-mm2/

A couple of crash fixes here.


Since 2.5.54-mm1:

+no-stem-compression.patch

 top(1) crashes for me.  Back out the stem compression code while
 it's being sorted out.

-quota-smp-locks.patch

 Merged

page_add_rmap-rework.patch

 Was causing an oops in X startup.   Fixed.

-teeny-mem-limits.patch
-smaller-head-arrays.patch
+#teeny-mem-limits.patch
+#smaller-head-arrays.patch

 Go back to the usual memory reserve levels.

+wli-11_pgd_ctor-update.patch

 Use pgds-from-slab and pmds-from-slab on non-PAE machines too.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
