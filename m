Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i8NMtSfM028713
	for <linux-mm@kvack.org>; Thu, 23 Sep 2004 15:55:28 -0700 (PDT)
Date: Thu, 23 Sep 2004 15:55:16 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: [Patch/RFC]Removing zone and node ID from page->flags[0/3]
Message-Id: <20040923135108.D8CC.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hello. 

I updated my patches which remove zone and node ID from page->flags.
Page->flags is 32bit space and 19 bits of them have already been used on
2.6.9-rc2-mm2 kernel, and zone and node ID uses 8 bits on 32 archtecture.
So, remaining bits is only 5 bits. In addition, only 3 bits have remained
on 2.6.8.1 stock kernel.

But, my patches make more 8 bits space in page->flags again.
And kernel can use large number of node and types of zone.

These patches are for 2.6.9-rc2-mm2. 

Please comment.

Bye.
-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
