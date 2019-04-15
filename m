Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52C05C282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BCD52183F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:15:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BCD52183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91E156B0003; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CF4C6B0007; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79BD66B0008; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 432986B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p11so11508123plr.3
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 08:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=dnEZfooHStwnMmAgeATkp6v8buJAv5PcJuj4rl9P134=;
        b=gEMPeyLxyq50kkOtr//Wh4bN+xSahUpANKtoORO+nVTdhBItbtZmgQC6TO1eoK30Mf
         8zWZP+In7kLF9jcv+4Bu26P++x0oqjc/gX08kZhI5wK+2prdzyJYzSFOb29b+gMF6Wh3
         82tsePh/ZMGOmnPUCZdN/ZBOSQjLNZBQly4vHhVVq/vGFfa5OMzpBONVFn1D3XB2urEj
         wTKtGs/irkb1EM9XFIZyc7nwgI7HTPQ8+6lzeltRfakQwf9DBJKW6fExzirZVgeXJMN0
         ERs+c5CgkgAiF6Kz8zAVWYpAk85ZiuJaSvcFTPJWKrDD+Rps9b3+x2hn4uecG5DZwhvr
         biSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWSUqRu+k2gRVT63nH2XRJMchtSKNbQdOxHChVN5YtluatiUITH
	xTNylyc0UJQEk5/g0njE+WHEIAadXwMnc4YYK32lZHsVT40qi4k17mCJ3417OmNVDJ7djISAkuu
	AuoLhcy/o4Tmz1671gSyteurPl7pWfBoovEm98WplytXWpH9+RHvPqr4MMertaSsdPA==
X-Received: by 2002:a17:902:599c:: with SMTP id p28mr13697901pli.70.1555341330927;
        Mon, 15 Apr 2019 08:15:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSn/1XNh25TMbiOKzGvxg5fIvg1L26zChtOlxSIWDG/NKfSjcCaKdD8LAI5djYlBGwZrcR
X-Received: by 2002:a17:902:599c:: with SMTP id p28mr13697818pli.70.1555341330007;
        Mon, 15 Apr 2019 08:15:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555341330; cv=none;
        d=google.com; s=arc-20160816;
        b=TL1vbPIrRsBiv71ATLya9vkJ3y0UL3yEJUBOgG+1h5hQl27JhfIeqleXzXZWCexXMl
         WfytczWmvNxglbwcSPHGkJoLrKF/QwP2Ndr8N4dmFwk9rYOGqUL1tfSvtByZr67xQts2
         HXAyPH2hkC5GqkF1gb8YeAfdnP6UqFGdFLXXH2VxFKnOAfFHE3Bs/zD8LrhM/e7n1+yV
         AwyP2axFm5w8nquPZvkuKMGjQ9HhvskYYe6wEFE1Sphmylya3dxMInht4R0w97v9XABX
         W1PKq+kmKa87jX1rp/URjfdj4WUxGQXyxWwo1AMwXXghkLNhcqN9lE75ZP7W/wJYc1So
         rmSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=dnEZfooHStwnMmAgeATkp6v8buJAv5PcJuj4rl9P134=;
        b=qq5YhSA8kLQ6glbLCCstAbwIdXQE9TwJZdy9lO1T2ZNM+M2anhiSmxseMeuoV6RNaA
         mMu9uh2KPJtjHViBzRiI4QsGtgVTYja7wgJVr5a6Fq3PwIIUVEbdQxDz9vHlLd/870e2
         i2RlcT+tASatL4B/NMp5Jxz5Nnf3q63mT1mXP7Dvg4RHEiHDRlHo7mQJ/PlaUuG0dAOF
         M8pf3iklUmydX8HEBR+TL25W3JdXJjA3X6havl7R+9LlaQSWq61ab5qTQTuE7+gy8SIP
         VukUkdlDhYWEyNjVOPAwyNmKdhGeDP56HDjO3DORSPqNV3r+gd32hJlROqxVNJMlo78F
         0luA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z72si44535592pgd.401.2019.04.15.08.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 08:15:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Apr 2019 08:15:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,354,1549958400"; 
   d="scan'208";a="149585858"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 15 Apr 2019 08:15:28 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org
Cc: Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 1/2] hmat: Register memory-side cache after parsing
Date: Mon, 15 Apr 2019 09:16:53 -0600
Message-Id: <20190415151654.15913-2-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190415151654.15913-1-keith.busch@intel.com>
References: <20190415151654.15913-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of registering the hmat cache attributes in line with parsing
the table, save the attributes in the memory target and register them
after parsing completes. This will make it easier to register the
attributes later when hot add is supported.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 48 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 33 insertions(+), 15 deletions(-)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index b7824a0309f7..bdb167c026ff 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -41,6 +41,7 @@ struct memory_target {
 	unsigned int memory_pxm;
 	unsigned int processor_pxm;
 	struct node_hmem_attrs hmem_attrs;
+	struct node_cache_attrs cache_attrs;
 };
 
 struct memory_initiator {
@@ -314,7 +315,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 				   const unsigned long end)
 {
 	struct acpi_hmat_cache *cache = (void *)header;
-	struct node_cache_attrs cache_attrs;
+	struct memory_target *target;
 	u32 attrs;
 
 	if (cache->header.length < sizeof(*cache)) {
@@ -328,37 +329,40 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 		cache->memory_PD, cache->cache_size, attrs,
 		cache->number_of_SMBIOShandles);
 
-	cache_attrs.size = cache->cache_size;
-	cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
-	cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
+	target = find_mem_target(cache->memory_PD);
+	if (!target)
+		return 0;
+
+	target->cache_attrs.size = cache->cache_size;
+	target->cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
+	target->cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
 
 	switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
 	case ACPI_HMAT_CA_DIRECT_MAPPED:
-		cache_attrs.indexing = NODE_CACHE_DIRECT_MAP;
+		target->cache_attrs.indexing = NODE_CACHE_DIRECT_MAP;
 		break;
 	case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
-		cache_attrs.indexing = NODE_CACHE_INDEXED;
+		target->cache_attrs.indexing = NODE_CACHE_INDEXED;
 		break;
 	case ACPI_HMAT_CA_NONE:
 	default:
-		cache_attrs.indexing = NODE_CACHE_OTHER;
+		target->cache_attrs.indexing = NODE_CACHE_OTHER;
 		break;
 	}
 
 	switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
 	case ACPI_HMAT_CP_WB:
-		cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
+		target->cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
 		break;
 	case ACPI_HMAT_CP_WT:
-		cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
+		target->cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
 		break;
 	case ACPI_HMAT_CP_NONE:
 	default:
-		cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
+		target->cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
 		break;
 	}
 
-	node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
 	return 0;
 }
 
@@ -577,20 +581,34 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
 	}
 }
 
+static __init void hmat_register_target_cache(struct memory_target *target)
+{
+	unsigned mem_nid = pxm_to_node(target->memory_pxm);
+	node_add_cache(mem_nid, &target->cache_attrs);
+}
+
 static __init void hmat_register_target_perf(struct memory_target *target)
 {
 	unsigned mem_nid = pxm_to_node(target->memory_pxm);
 	node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
 }
 
+static __init void hmat_register_target(struct memory_target *target)
+{
+	if (!node_online(pxm_to_node(target->memory_pxm)))
+		return;
+
+	hmat_register_target_initiators(target);
+	hmat_register_target_cache(target);
+	hmat_register_target_perf(target);
+}
+
 static __init void hmat_register_targets(void)
 {
 	struct memory_target *target;
 
-	list_for_each_entry(target, &targets, node) {
-		hmat_register_target_initiators(target);
-		hmat_register_target_perf(target);
-	}
+	list_for_each_entry(target, &targets, node)
+		hmat_register_target(target);
 }
 
 static __init void hmat_free_structures(void)
-- 
2.14.4

