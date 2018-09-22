Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37D6B8E0001
	for <linux-mm@kvack.org>; Sat, 22 Sep 2018 10:53:58 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 3-v6so7496009plq.6
        for <linux-mm@kvack.org>; Sat, 22 Sep 2018 07:53:58 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id h14-v6si29898117pgg.540.2018.09.22.07.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 22 Sep 2018 07:53:56 -0700 (PDT)
From: <zhe.he@windriver.com>
Subject: [PATCH v2 2/2] mm/page_alloc: Add KBUILD_MODNAME
Date: Sat, 22 Sep 2018 22:53:33 +0800
Message-ID: <1537628013-243902-2-git-send-email-zhe.he@windriver.com>
In-Reply-To: <1537628013-243902-1-git-send-email-zhe.he@windriver.com>
References: <1537628013-243902-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, osalvador@suse.de, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhe.he@windriver.com

From: He Zhe <zhe.he@windriver.com>

Add KBUILD_MODNAME to make prints more clear.

Signed-off-by: He Zhe <zhe.he@windriver.com>
Cc: akpm@linux-foundation.org
Cc: mhocko@suse.com
Cc: vbabka@suse.cz
Cc: pasha.tatashin@oracle.com
Cc: mgorman@techsingularity.net
Cc: aaron.lu@intel.com
Cc: osalvador@suse.de
Cc: iamjoonsoo.kim@lge.com
---
v2:
Split the addition of KBUILD_MODNAME out

 mm/page_alloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f34cae1..ead9556 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -14,6 +14,8 @@
  *          (lots of bits borrowed from Ingo Molnar & Andrew Morton)
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/stddef.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
-- 
2.7.4
