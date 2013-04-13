Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 1CF7A6B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:43:48 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v14so1862256pde.32
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:43:47 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 15/19] mm/ARM: fix stale comment about VALID_PAGE()
Date: Sat, 13 Apr 2013 23:36:35 +0800
Message-Id: <1365867399-21323-16-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>, Stephen Boyd <sboyd@codeaurora.org>, Giancarlo Asnaghi <giancarlo.asnaghi@st.com>, linux-arm-kernel@lists.infradead.org

VALID_PAGE() has been removed from kernel long time ago,
so fix the comment.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Nicolas Pitre <nico@linaro.org>
Cc: Stephen Boyd <sboyd@codeaurora.org>
Cc: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/include/asm/memory.h |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
index 57870ab..0cd2a3d 100644
--- a/arch/arm/include/asm/memory.h
+++ b/arch/arm/include/asm/memory.h
@@ -260,12 +260,6 @@ static inline __deprecated void *bus_to_virt(unsigned long x)
 /*
  * Conversion between a struct page and a physical address.
  *
- * Note: when converting an unknown physical address to a
- * struct page, the resulting pointer must be validated
- * using VALID_PAGE().  It must return an invalid struct page
- * for any physical address not corresponding to a system
- * RAM address.
- *
  *  page_to_pfn(page)	convert a struct page * to a PFN number
  *  pfn_to_page(pfn)	convert a _valid_ PFN number to struct page *
  *
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
