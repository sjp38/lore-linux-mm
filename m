Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 169D06B0255
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 03:50:11 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so228512587pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 00:50:10 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id vz2si3790402pbc.164.2015.11.10.00.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 00:50:10 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so228512269pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 00:50:10 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] tools/vm/page-types.c: support KPF_IDLE
Date: Tue, 10 Nov 2015 17:50:04 +0900
Message-Id: <1447145404-5589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

PageIdle is exported in include/uapi/linux/kernel-page-flags.h, so let's
make page-types.c tool handle it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/vm/page-types.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git mmotm-2015-10-21-14-41/tools/vm/page-types.c mmotm-2015-10-21-14-41_patched/tools/vm/page-types.c
index 7f73fa3..d70de63 100644
--- mmotm-2015-10-21-14-41/tools/vm/page-types.c
+++ mmotm-2015-10-21-14-41_patched/tools/vm/page-types.c
@@ -128,6 +128,7 @@ static const char * const page_flag_names[] = {
 	[KPF_THP]		= "t:thp",
 	[KPF_BALLOON]		= "o:balloon",
 	[KPF_ZERO_PAGE]		= "z:zero_page",
+	[KPF_IDLE]              = "i:idle_page",
 
 	[KPF_RESERVED]		= "r:reserved",
 	[KPF_MLOCKED]		= "m:mlocked",
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
