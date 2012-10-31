Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 0FD736B0070
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 05:16:02 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART5 Patch 3/5] x86: use memblock_set_current_limit() to set memblock.current_limit
Date: Wed, 31 Oct 2012 17:21:41 +0800
Message-Id: <1351675303-11786-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351675303-11786-1-git-send-email-wency@cn.fujitsu.com>
References: <1351675303-11786-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

memblock.current_limit is set directly though memblock_set_current_limit()
is prepared. So fix it.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index ca45696..ab3017a 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -890,7 +890,7 @@ void __init setup_arch(char **cmdline_p)
 
 	cleanup_highmap();
 
-	memblock.current_limit = get_max_mapped();
+	memblock_set_current_limit(get_max_mapped());
 	memblock_x86_fill();
 
 	/*
@@ -940,7 +940,7 @@ void __init setup_arch(char **cmdline_p)
 		max_low_pfn = max_pfn;
 	}
 #endif
-	memblock.current_limit = get_max_mapped();
+	memblock_set_current_limit(get_max_mapped());
 	dma_contiguous_reserve(0);
 
 	/*
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
