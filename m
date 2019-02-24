Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C02DC43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BF31206B6
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cMZn/ghO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BF31206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 010EF8E0160; Sun, 24 Feb 2019 07:34:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDB8F8E015B; Sun, 24 Feb 2019 07:34:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7DBE8E0160; Sun, 24 Feb 2019 07:34:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91CEA8E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 07:34:44 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 23so5011293pgr.11
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 04:34:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Ugvldidm8y8s0n/p3Bwr6/2IroSyDjrqAPqWfyI4hQA=;
        b=ZEXh0cLmOZ10ztkUXNdHothFQMp23WP5j5OqGyH4sg+hmJrzdPKiEE1kMfkffvdtYb
         63VgEc84S6YMB0vofL8DB42rL1EdpwFwVjV/Ygr2YYN7y4psrm0FfugwCdZPNx+9EVJC
         TtbSEmfp0ew2K/6x35k7sLTGovj9ReRl8cyxhQRzHCfD4tD+q5vOYJNf9j8LYulzbTzk
         jYdxo0QqVi1s7Kc4SXRBxYajQQUVzo1D0eJwGqM7orkCKcsEe5e6FNKpVELbM0JIAAfx
         CO6AOX2zC/HXugaZ/8MvO2EZs42OnFWom8AMdAkX+pv28MA8IEXufVdG9IquLjBIeP3q
         NUmg==
X-Gm-Message-State: AHQUAuZiZPg4skNFUbYfzDy6FwsyXMiMpQUpMFv+Z0oh6AyQtbWHwJ50
	iEfV31kOFrCdPXuBeESMeF7/GIx/7TiPWuqvuxtSWnR+bVEVLs0u7X0w9uwhQHPWjq0TREI+UyB
	Qgz9kabTWAXffMNerx72VLYbcCZ/ADFjIu6vXvNmtQj6R3p8szNgWRyaemtxMBYeFzb5CAe4xsu
	N16nR3mFVFIOf2nNF+lR+0xyO4UQ97Z2rgTBmB5/6xUO9puqC+0udW2mnQchfhuD1dAvLrRNYiE
	LAiCBQsnZcRSOth3Z8xrSixrrpQSvPWJBev1BpyH9MnupMCW94TEWDawGU24tmDMKzRdVrQsKyB
	vhZKdEKVdXHIc6ShGPQt2zT/l3cBbsCEpR8yf/6EfaB9mKAcDYK0Yh1WbvAXAUFnHWwkCK4tS3f
	O
X-Received: by 2002:a63:535c:: with SMTP id t28mr12970319pgl.128.1551011684194;
        Sun, 24 Feb 2019 04:34:44 -0800 (PST)
X-Received: by 2002:a63:535c:: with SMTP id t28mr12970188pgl.128.1551011682765;
        Sun, 24 Feb 2019 04:34:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551011682; cv=none;
        d=google.com; s=arc-20160816;
        b=u+z5eViYrxtncG8OB74y8SwNqCKlatq7+Ekj46BZfnhQSYzI67yRdodTCVfDxN4SZm
         JMiXriFe6aRYNyp7t03TjxIZu9B6bloNEfBkOSF5JW1o0H7BIc40hKRNC4dfiA6Tqdcb
         GpRhoEbomrF1TXtytdxrX/zIRxO+IV9tjLFRoXlnpApyxZk+NOY7Fxv1xAn02b2R9JdD
         QxkN1+iKHAFNYdobyFmgjlHfsg8DNOsUz+fMpVGERrxcM22z8ZGkpIQvdckT4TT8kq9F
         Ynp0lSP30NPGwdabUivuJz4oak8c9r4Fk962fjuICoa8uU1gbep3MZ8OqRcAoJ5bG1Aw
         Cd1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Ugvldidm8y8s0n/p3Bwr6/2IroSyDjrqAPqWfyI4hQA=;
        b=GQeJtB0xjGBzcxf/oKyqF+R0EicPkOz8aFhq+Z4WtuYdITukDP4MGdQLQfmeMlzgwi
         pI1u0NHaDcUpuKIdJ9MroDjpcLnSSLonRoWjF7tCKV7318O2dTQRRcZiogvfujPvJRTB
         sbGmnfUAo1n8gpqP+pSq2XOutHAFsFboPz1e26Xazuo4YJHcNE9xMoJ82RasqO6IfZKY
         zIYN3sVYzLeD/SHbTYkHUn4DMfxft0BDjv69Fl+k5DV1A/XMpZJHTDpK/70gIp7wMt49
         DZSqvQQKpAjsh88rZn0YitzoDHJlpslXF4KYMIyazmmqw8xk0eV45WBzHrWMqKHRGaMf
         CcmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="cMZn/ghO";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h29sor4317627pgh.11.2019.02.24.04.34.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 04:34:42 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="cMZn/ghO";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=Ugvldidm8y8s0n/p3Bwr6/2IroSyDjrqAPqWfyI4hQA=;
        b=cMZn/ghOVis+vQJBy5AyjcvJO3oUfeQIhP/N8EAe5khMGJLUnJ+pjcDuzDLz+77iE7
         aWkDKpgMy/nlXiTbdrmuB9fIm4Ulcc+WaLgKqzpLLuLjyy7adnT1otiz0O80y9Qp5gkr
         64AuxOzb044cSeNVLuNT8+PnPENYfap1nbA4WIqkumt3WD/TKn9xSI0XPYa8QAZUUHb8
         7gEo3nyyRcMjcMj9EMTsHQyRmZVdkXL8Mw2JPXtaixFJUDJ8SKW2IFfrRThZVIQ7JBX4
         RX5icrMFScd68STF3eajyPao2v2fhVB66P+xRmZRrrg68vwv+2vf4WZ/r+H/k4VUVG3g
         UeOw==
X-Google-Smtp-Source: AHgI3IaaMGmFqz42VyRjWubPjFaekxnIRYmn3Cp9WJ7o4X5kSGWGaI22WGXOUXgvJaO05xTxZx5sAw==
X-Received: by 2002:a63:4346:: with SMTP id q67mr12530406pga.92.1551011682473;
        Sun, 24 Feb 2019 04:34:42 -0800 (PST)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v6sm9524634pgb.2.2019.02.24.04.34.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 04:34:41 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
To: x86@kernel.org,
	linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andy Lutomirski <luto@kernel.org>,
	Andi Kleen <ak@linux.intel.com>,
	Petr Tesarik <ptesarik@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jonathan Corbet <corbet@lwn.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Daniel Vacek <neelx@redhat.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/6] mm/memblock: make full utilization of numa info
Date: Sun, 24 Feb 2019 20:34:05 +0800
Message-Id: <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are numa machines with memory-less node. When allocating memory for
the memory-less node, memblock allocator falls back to 'Node 0' without fully
utilizing the nearest node. This hurts the performance, especially for per
cpu section. Suppressing this defect by building the full node fall back
info for memblock allocator, like what we have done for page allocator.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@redhat.com>
CC: Borislav Petkov <bp@alien8.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
CC: Andy Lutomirski <luto@kernel.org>
CC: Andi Kleen <ak@linux.intel.com>
CC: Petr Tesarik <ptesarik@suse.cz>
CC: Michal Hocko <mhocko@suse.com>
CC: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Jonathan Corbet <corbet@lwn.net>
CC: Nicholas Piggin <npiggin@gmail.com>
CC: Daniel Vacek <neelx@redhat.com>
CC: linux-kernel@vger.kernel.org
---
 include/linux/memblock.h |  3 +++
 mm/memblock.c            | 68 ++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 66 insertions(+), 5 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 64c41cf..ee999c5 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -342,6 +342,9 @@ void *memblock_alloc_try_nid_nopanic(phys_addr_t size, phys_addr_t align,
 void *memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
 			     phys_addr_t min_addr, phys_addr_t max_addr,
 			     int nid);
+extern int build_node_order(int *node_oder_array, int sz,
+	int local_node, nodemask_t *used_mask);
+void memblock_build_node_order(void);
 
 static inline void * __init memblock_alloc(phys_addr_t size,  phys_addr_t align)
 {
diff --git a/mm/memblock.c b/mm/memblock.c
index 022d4cb..cf78850 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1338,6 +1338,47 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
+static int **node_fallback __initdata;
+
+/*
+ * build_node_order() relies on cpumask_of_node(), hence arch should set up
+ * cpumask before calling this func.
+ */
+void __init memblock_build_node_order(void)
+{
+	int nid, i;
+	nodemask_t used_mask;
+
+	node_fallback = memblock_alloc(MAX_NUMNODES * sizeof(int *),
+		sizeof(int *));
+	for_each_online_node(nid) {
+		node_fallback[nid] = memblock_alloc(
+			num_online_nodes() * sizeof(int), sizeof(int));
+		for (i = 0; i < num_online_nodes(); i++)
+			node_fallback[nid][i] = NUMA_NO_NODE;
+	}
+
+	for_each_online_node(nid) {
+		nodes_clear(used_mask);
+		node_set(nid, used_mask);
+		build_node_order(node_fallback[nid], num_online_nodes(),
+			nid, &used_mask);
+	}
+}
+
+static void __init memblock_free_node_order(void)
+{
+	int nid;
+
+	if (!node_fallback)
+		return;
+	for_each_online_node(nid)
+		memblock_free(__pa(node_fallback[nid]),
+			num_online_nodes() * sizeof(int));
+	memblock_free(__pa(node_fallback), MAX_NUMNODES * sizeof(int *));
+	node_fallback = NULL;
+}
+
 /**
  * memblock_alloc_internal - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
@@ -1370,6 +1411,7 @@ static void * __init memblock_alloc_internal(
 {
 	phys_addr_t alloc;
 	void *ptr;
+	int node;
 	enum memblock_flags flags = choose_memblock_flags();
 
 	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
@@ -1397,11 +1439,26 @@ static void * __init memblock_alloc_internal(
 		goto done;
 
 	if (nid != NUMA_NO_NODE) {
-		alloc = memblock_find_in_range_node(size, align, min_addr,
-						    max_addr, NUMA_NO_NODE,
-						    flags);
-		if (alloc && !memblock_reserve(alloc, size))
-			goto done;
+		if (!node_fallback) {
+			alloc = memblock_find_in_range_node(size, align,
+					min_addr, max_addr,
+					NUMA_NO_NODE, flags);
+			if (alloc && !memblock_reserve(alloc, size))
+				goto done;
+		} else {
+			int i;
+			for (i = 0; i < num_online_nodes(); i++) {
+				node = node_fallback[nid][i];
+				/* fallback list has all memory nodes */
+				if (node == NUMA_NO_NODE)
+					break;
+				alloc = memblock_find_in_range_node(size,
+						align, min_addr, max_addr,
+						node, flags);
+				if (alloc && !memblock_reserve(alloc, size))
+					goto done;
+			}
+		}
 	}
 
 	if (min_addr) {
@@ -1969,6 +2026,7 @@ unsigned long __init memblock_free_all(void)
 
 	reset_all_zones_managed_pages();
 
+	memblock_free_node_order();
 	pages = free_low_memory_core_early();
 	totalram_pages_add(pages);
 
-- 
2.7.4

