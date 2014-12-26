Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id BFC726B006C
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 14:02:50 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so14898467wgg.39
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 11:02:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fs8si43670628wib.87.2014.12.26.11.02.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Dec 2014 11:02:49 -0800 (PST)
Date: Fri, 26 Dec 2014 20:02:09 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/1] blackfin: bf533-stamp: add linux/delay.h
Message-ID: <20141226190209.GB15032@redhat.com>
References: <201412252014.vyXxH1Bh%fengguang.wu@intel.com> <20141226190150.GA15032@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141226190150.GA15032@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Steven Miao <realmz6@gmail.com>, Mike Frysinger <vapier@gentoo.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

build error
arch/blackfin/mach-bf533/boards/stamp.c:834:2: error: implicit declaration of function 'mdelay'

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 arch/blackfin/mach-bf533/boards/stamp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/blackfin/mach-bf533/boards/stamp.c b/arch/blackfin/mach-bf533/boards/stamp.c
index 6f4bac9..23eada7 100644
--- a/arch/blackfin/mach-bf533/boards/stamp.c
+++ b/arch/blackfin/mach-bf533/boards/stamp.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/device.h>
+#include <linux/delay.h>
 #include <linux/platform_device.h>
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/partitions.h>
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
