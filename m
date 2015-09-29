Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2608C6B0254
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 18:03:39 -0400 (EDT)
Received: by igxx6 with SMTP id x6so17664057igx.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 15:03:39 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id l1si19010239ioe.197.2015.09.29.15.03.38
        for <linux-mm@kvack.org>;
        Tue, 29 Sep 2015 15:03:38 -0700 (PDT)
Date: Wed, 30 Sep 2015 06:01:52 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: fs/jffs2/wbuf.c:1267:2-3: Unneeded semicolon
Message-ID: <201509300650.TRylB4T8%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Sasha,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   097f70b3c4d84ffccca15195bdfde3a37c0a7c0f
commit: 71458cfc782eafe4b27656e078d379a34e472adf kernel: add support for gcc 5
date:   12 months ago


coccinelle warnings: (new ones prefixed by >>)

>> fs/jffs2/wbuf.c:1267:2-3: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
