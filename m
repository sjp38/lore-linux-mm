Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB096B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:34:13 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 104so15193485uat.5
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 08:34:13 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id l27si5177105uaf.322.2018.02.14.08.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 08:34:12 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v4 0/1] initialize pages on demand during boot
Date: Wed, 14 Feb 2018 11:33:42 -0500
Message-Id: <20180214163343.21234-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch replaces in mmots:
	mm-initialize-pages-on-demand-during-boot.patch
	mm-initialize-pages-on-demand-during-boot-fix.patch
	mm-initialize-pages-on-demand-during-boot-fix2.patch

It squashes the two fixes into the original patch, and also in:
deferred_grow_zone()

Replaces:
+	int nid = zone->node;
With:
+	int nid = zone_to_nid(zone);

To resolve !CONFIG_NUMA compiling issue that was reported by Sergey
Senozhatsky.

Pavel Tatashin (1):
  mm: initialize pages on demand during boot

 include/linux/memblock.h |  10 ---
 mm/memblock.c            |  23 -------
 mm/page_alloc.c          | 175 ++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 136 insertions(+), 72 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
