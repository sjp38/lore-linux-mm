Received: from asdc.com.cn ([9.196.36.117]) by ultra.asdc-beijing.com
          (Netscape Mail Server v2.02) with ESMTP id AAA13381
          for <linux-mm@kvack.org>; Mon, 14 Jun 1999 15:37:01 +0800
Message-ID: <3765243A.8926786B@asdc.com.cn>
Date: Mon, 14 Jun 1999 15:48:11 +0000
From: ZhangWeiXue <ZhangWeiXue@asdc.com.cn>
Reply-To: ZhangWeiXue@asdc.com.cn
MIME-Version: 1.0
Subject: I do not know what the code means.
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dear all,

The following code is cut from the head.s, I do not know exactly what it
do?
If you can explain the meaning of " .long 0x00102007 " and " .fill
__USER_PGD_PTRS-1,4,0" for me,
I will appreciate deeply.
Best regards.

/*
 * This is initialized to create a identity-mapping at 0-4M (for bootup
 * purposes) and another mapping of the 0-4M area at virtual address
 * PAGE_OFFSET.
 */
.org 0x1000
ENTRY(swapper_pg_dir)
 .long 0x00102007
 .fill __USER_PGD_PTRS-1,4,0
 /* default: 767 entries */
 .long 0x00102007
 /* default: 255 entries */
 .fill __KERNEL_PGD_PTRS-1,4,0



--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
