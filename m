Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD666B0039
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:32:06 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so255845pde.6
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:32:06 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id yd9si9446968pab.263.2014.01.22.03.31.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 03:32:05 -0800 (PST)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 0/3] Bugfix for kdump on arm
Date: Wed, 22 Jan 2014 19:25:13 +0800
Message-ID: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kexec@lists.infradead.org
Cc: Eric Biederman <ebiederm@xmission.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Geng Hui <hui.geng@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

This patch series introduce 3 bugfix for kdump (and kexec) on arm platform.

kdump for arm in fact is corrupted (at least for omap4460). With one-month hard
work and with the help of a jtag debugger, we finally make kdump works
reliablly.


Following is the patches. The first 2 patches forms a group, it allow
ioremap_nocache to be taken on reserved pages on arm platform (which is
prohibited by 309caa9cc) and then use ioremap_nocache to copy kexec required
code. The last 1 is for crash dump kernel. It allow kernel to be loaded in the
middle of kernel awared physical memory. Without it, crashdump kernel must be
carefully configured to boot.

Wang Nan (3):
  ARM: Premit ioremap() to map reserved pages
  ARM: kexec: copying code to ioremapped area
  ARM: allow kernel to be loaded in middle of phymem

 arch/arm/kernel/machine_kexec.c | 18 ++++++++++++++++--
 arch/arm/mm/init.c              | 21 ++++++++++++++++++++-
 arch/arm/mm/ioremap.c           |  2 +-
 arch/arm/mm/mmu.c               | 13 +++++++++++++
 kernel/kexec.c                  | 40 +++++++++++++++++++++++++++++++++++-----
 mm/page_alloc.c                 |  7 +++++--
 6 files changed, 90 insertions(+), 11 deletions(-)


Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Geng Hui <hui.geng@huawei.com>

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
