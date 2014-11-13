Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8BE6B00D5
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 07:24:09 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so4144087wiw.16
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 04:24:08 -0800 (PST)
Received: from cvs.linux-mips.org (eddie.linux-mips.org. [148.251.95.138])
        by mx.google.com with ESMTP id ky4si20364220wjc.109.2014.11.13.04.24.08
        for <linux-mm@kvack.org>;
        Thu, 13 Nov 2014 04:24:08 -0800 (PST)
Received: from localhost.localdomain ([127.0.0.1]:51614 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27013422AbaKMMYHrAK7h (ORCPT <rfc822;linux-mm@kvack.org>);
        Thu, 13 Nov 2014 13:24:07 +0100
Date: Thu, 13 Nov 2014 13:24:06 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Impact of removing VM_EXEC from brk area
Message-ID: <20141113122406.GA19763@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, libc-alpha@sourceware.org

A patch to remove VM_EXEC from VM_DATA_DEFAULT_FLAGS for MIPS has been
submitted to me with the primary motivation for this change being
some performance improvment.  In other words, the patch would remove
execute permission from a process brk area.  It's however unclear to
me how much software wreckage would result from such a change, even
if the execute permission for the stack area remains unchanged.

So, what would break?

Thanks,

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
