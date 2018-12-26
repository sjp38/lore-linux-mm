Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92169C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:39:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A3D4218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:39:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A3D4218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA66A8E0008; Wed, 26 Dec 2018 08:39:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2E198E0001; Wed, 26 Dec 2018 08:39:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCF488E0008; Wed, 26 Dec 2018 08:39:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85EA58E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:39:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x7so13954102pll.23
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:39:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=tYqj7DG34CtC/nTD0z3u9A6Jj04pHSJsobbAtn39leM=;
        b=FnTmIa8o8n8wqNnCo7AXuwICmslr1PzBG75NnsFeltY+7sDaMiNsnxlGx/x0e2+oPt
         /5TP5bIQCYyAjbHcPCv0N/nSdaler4V4DYuZcDnZWSInrYF89xYRjSvgKy7dIk4TCkis
         DGR5I3UDYR9Hh7SQJCFbM8/LoUhIwKslT0Gj38JZARq+/pddfDUC0GeAxo6Fi3zRFL2O
         zB2gzBswNz4Yud1JGyXRMh6yLTL4JKG8KoWBCMCE3cMHMkn4F1OuafASG3t/hFcdRzgK
         SMWQGDyLQ/7bLRUwF2oyXfFTcHKIAsFeIrU4FDIpLl46Qb0KaZs3FBDzWUOm+Fu4yweU
         yg3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWaXTiCy33zNGQ1obQ1YubCMa9w3EbzEY7amV+Nx/5gkrFRPXLwV
	gCJQp3vZrbxVzZaHHUEkONQf20X45QTAzhF3PM6hvnD3PIuF5YgbPxWKGToFyOxzA78KllCN9Zy
	3R6Rh28YDKRBMG5/4aeZ5UIMIWtimxsskrUAp0OwUrDqJ/JJdGWwXB8ohOEF7wQC60w==
X-Received: by 2002:a62:dbc2:: with SMTP id f185mr20046327pfg.235.1545831543226;
        Wed, 26 Dec 2018 05:39:03 -0800 (PST)
X-Google-Smtp-Source: AFSGD/V+2q9ausOlvfFXMvIV9VjxLCl9AKgR/vGCKA3e7e8K3baMNF3MrhGeYh+zo3tpH0/Z2Iyn
X-Received: by 2002:a62:dbc2:: with SMTP id f185mr20040484pfg.235.1545831427188;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=pxqEvYYyt0kxnu7j8l8GmVmmUzhs4zNsI0FyLmsSwIU5/Ym2WGCZoDeiiVnzpIvb+6
         3xXsWpH7TzWo6ZNiRKwRNdQQKLTeauDiUqVMEg46vXSqzhN27UpwzU4vmZqNBABkR348
         kn6jJpaekbNqLo7q9iXTiNNggfGjAlV9ThrVynRUrVnL9Fcn1P1XiqaGe3/cpE2UCrpJ
         nZEE5Q9z2myKRCMNpskrtVbNwCLzAopQfumXDCKIzOfCKg0ARVwjkB94LlJlvmYp5GLi
         JOOfdpaeIiZAI9j4cRq34j4eQhJGyeLWzdgAI7CflbsO0hxMOxWyGjSNNKYy8OWVcZGi
         gvmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=tYqj7DG34CtC/nTD0z3u9A6Jj04pHSJsobbAtn39leM=;
        b=OAYdvtNwhPMmPyMEOyqMpG/WP10OqEXHmlDeusllYBJ/AUHzp2qxmrjvQGopAL7P9H
         JRAAEe88DYCd5G7nVgQ3sZ+fr5WK66M87Dxc5/vNmkVI4VuZhkU0Wnd5ooHyIJsySx3c
         cg6sirlNMcdWz7v/wv0uQleje3LtuQv5/QYCG+MhsMfaOVZw6oQCwcd5/3I6160AkFpn
         IubL3T0oB0EStw1Z6TBUeep/tG70FbS/4YLWT9qjSsVYHTmdUDQvisT7HV2dddyex87k
         Md0UEDiGmnjpRPpa4g08r9BOMbtInYblbmZYWscVKK4BpTXUMMPyIUmjzKTUlzb2b3/2
         nyNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185471"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005PS-Ms; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133352.246320288@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:15:06 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>,
 Jingqi Liu <jingqi.liu@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 20/21] mm/vmscan.c: migrate anon DRAM pages to PMEM node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0012-vmscan-migrate-anonymous-pages-to-pmem-node-before-s.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131506.ck_T_IQCTyFyc-dPmKVdypBPEM8IDLPQqtcAqyKopXk@z>

From: Jingqi Liu <jingqi.liu@intel.com>

With PMEM nodes, the demotion path could be

1) DRAM pages: migrate to PMEM node
2) PMEM pages: swap out

This patch does (1) for anonymous pages only. Since we cannot
detect hotness of (unmapped) page cache pages for now.

The user space daemon can do migration in both directions:
- PMEM=>DRAM hot page migration
- DRAM=>PMEM cold page migration
However it's more natural for user space to do hot page migration
and kernel to do cold page migration. Especially, only kernel can
guarantee on-demand migration when there is memory pressure.

So the big picture will look like this: user space daemon does regular
hot page migration to DRAM, creating memory pressure on DRAM nodes,
which triggers kernel cold page migration to PMEM nodes.

Du Fan:
- Support multiple NUMA nodes.
- Don't migrate clean MADV_FREE pages to PMEM node.

With advise(MADV_FREE) syscall, both vma structure and
its corresponding page entries still lives, but we got
MADV_FREE page, anonymous but WITHOUT SwapBacked.

In case of page reclaim, clean MADV_FREE pages will be
freed and return to buddy system, the dirty ones then
turn into canonical anonymous page with
PageSwapBacked(page) set, and put into LRU_INACTIVE_FILE
list falling into standard aging routine.

Point is clean MADV_FREE pages should not be migrated,
it has steal (useless) user data once madvise(MADV_FREE)
called and guard against thus scenarios.

P.S. MADV_FREE is heavily used by jemalloc engine, and
workload like redis, refer to [1] for detailed backgroud,
usecase, and benchmark result.

[1]
https://lore.kernel.org/patchwork/patch/622179/

Fengguang:
- detect migrate thp and hugetlb
- avoid moving pages to a non-existent node

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Jingqi Liu <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/vmscan.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

--- linux.orig/mm/vmscan.c	2018-12-23 20:37:58.305551976 +0800
+++ linux/mm/vmscan.c	2018-12-23 20:37:58.305551976 +0800
@@ -1112,6 +1112,7 @@ static unsigned long shrink_page_list(st
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(move_pages);
 	int pgactivate = 0;
 	unsigned nr_unqueued_dirty = 0;
 	unsigned nr_dirty = 0;
@@ -1121,6 +1122,7 @@ static unsigned long shrink_page_list(st
 	unsigned nr_immediate = 0;
 	unsigned nr_ref_keep = 0;
 	unsigned nr_unmap_fail = 0;
+	int page_on_dram = is_node_dram(pgdat->node_id);
 
 	cond_resched();
 
@@ -1275,6 +1277,21 @@ static unsigned long shrink_page_list(st
 		}
 
 		/*
+		 * Check if the page is in DRAM numa node.
+		 * Skip MADV_FREE pages as it might be freed
+		 * immediately to buddy system if it's clean.
+		 */
+		if (node_online(pgdat->peer_node) &&
+			PageAnon(page) && (PageSwapBacked(page) || PageTransHuge(page))) {
+			if (page_on_dram) {
+				/* Add to the page list which will be moved to pmem numa node. */
+				list_add(&page->lru, &move_pages);
+				unlock_page(page);
+				continue;
+			}
+		}
+
+		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 * Lazyfree page could be freed directly
@@ -1496,6 +1513,22 @@ keep:
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	/* Move the anonymous pages to PMEM numa node. */
+	if (!list_empty(&move_pages)) {
+		int err;
+
+		/* Could not block. */
+		err = migrate_pages(&move_pages, alloc_new_node_page, NULL,
+					pgdat->peer_node,
+					MIGRATE_ASYNC, MR_NUMA_MISPLACED);
+		if (err) {
+			putback_movable_pages(&move_pages);
+
+			/* Join the pages which were not migrated.  */
+			list_splice(&ret_pages, &move_pages);
+		}
+	}
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);


