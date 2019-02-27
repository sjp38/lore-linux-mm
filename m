Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FB97C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 534EE2133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 534EE2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8EB28E000E; Wed, 27 Feb 2019 17:50:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B44CB8E0004; Wed, 27 Feb 2019 17:50:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96A6B8E000E; Wed, 27 Feb 2019 17:50:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5080A8E0004
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 17:50:37 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 2so13289364pgg.21
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:50:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=0HjwwT6eQeqhzAbFDcuq0ldWENBawT6qQh3pTSR0FdA=;
        b=FrE4pajLWaQk8cu5UJCl+dvG0OOimz2p17YBL4Q35FoGQZgjQtkzKRK5Pe24DnTaWR
         EtScaXZPrHyVTHYI6ckQYUQPo0owOJXLJulhKRkAQD9eYuxhBDJQKitxi+aJp6CebOIQ
         hTaxzEsf/MTUCuKpZNjoMMuQfFem+dKpCPZKSF1zY4BaZcglT4fespkyTJfsFexBcvHc
         8BKSuvrrV9Z7TGlyptGJVRxJaFCj0sxai2BAl0O7egTPUqWb2qvjN1j6i7DQqjC7A0US
         eO1rS53z2+x3jmqP5lsP4pFoH3YU204TTGd0lSKASDjH4sDdKZDSj0e3+bzbreK2wj6X
         6mmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYAFQnSepe982NEngMGS/Q4pV1jnu9FHeqtU9QjKpuJO3ZG8xkz
	X/0uqN6ipODjJeFxmOyKjqiAy7QViBKqSTVmf93AePKnEaECQvTklLJoGdEbUpJXOj1lS2GEhio
	SNA/zdBS/Euvde8m1JgmhIHUZJ7oc2Cdkv74fLty+0V94dv97UCkNtm6yY2ZquLd88A==
X-Received: by 2002:a62:b2d9:: with SMTP id z86mr4139941pfl.255.1551307836984;
        Wed, 27 Feb 2019 14:50:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbNBMG9mxUNFCX91naF5L+5S6xvQOJ/V73m6Uw9JHjQd2tPcUSOvpXXyRJffG2aZVr07Y8f
X-Received: by 2002:a62:b2d9:: with SMTP id z86mr4139871pfl.255.1551307835979;
        Wed, 27 Feb 2019 14:50:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551307835; cv=none;
        d=google.com; s=arc-20160816;
        b=FPXR/BOmWjtZidWquqUpDyqjQdivDhvAcfjoLkJzg/sQPCWPUz1GpzDVmIqDTOjgco
         bZgxqHTaQ7ulM/pmeflveWuJrIEXz8jFM+vl42axNCskhw1yeDAtMPGT3Kgpz7MB/APT
         qqm2ci2yi0UNY9hS2GNxhYOLb5IfkhfscYT2QNScWhYXj4FToMXRnoyzL0NlHXH0P/Xi
         uUtqEwPWi2lZ4LpgumS9rC5m3VEr/2VHTM8uVGKQsqq63PT0r4e48MIDBEa4KZ70cR0w
         9a7lNW+WeqfAI05Kqk5S6U2nQ5LlJ0iNq3efNI6tcxHHEplHMZMghH6xrNlIxIdHW7KO
         HTAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=0HjwwT6eQeqhzAbFDcuq0ldWENBawT6qQh3pTSR0FdA=;
        b=TXIBtvUECp9k7DG59qRQOxPsZMJicCQFtdH6DxTmrOHwwT6mdKshKy5zykR2Ls7WnV
         FuUWBXCDauNzhgEZG2g3UNood+oXvgKXYmigdmtcyKbHp8LbKVAckPaP5ze3XHen37+X
         gU6E87kP1cftjYsx/G81Tq6XMGiYuBNNK3oQV2r57krI4NfMrCLS+xXCqWSd0bcYyZBN
         b6hz4fCU+l2wIrIJtuWwadIAAncMxisWLRodd8dozay+ngVakDUfsIMst95jEoq7jEd3
         O8ymtF37aEy3uEAc7nZRANt0Pl4P/Xhy/HU03Q1OeJbxrNMbudkz+KVuYP9KVol0lOOl
         87+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z20si10836901pgf.324.2019.02.27.14.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 14:50:35 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 14:50:35 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="121349436"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 27 Feb 2019 14:50:34 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv7 09/10] acpi/hmat: Register memory side cache attributes
Date: Wed, 27 Feb 2019 15:50:37 -0700
Message-Id: <20190227225038.20438-10-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190227225038.20438-1-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Register memory side cache attributes with the memory's node if HMAT
provides the side cache iniformation table.

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 5b469c98a454..f3b182bf3595 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -314,6 +314,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 				   const unsigned long end)
 {
 	struct acpi_hmat_cache *cache = (void *)header;
+	struct node_cache_attrs cache_attrs;
 	u32 attrs;
 
 	if (cache->header.length < sizeof(*cache)) {
@@ -327,6 +328,37 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 		cache->memory_PD, cache->cache_size, attrs,
 		cache->number_of_SMBIOShandles);
 
+	cache_attrs.size = cache->cache_size;
+	cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
+	cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
+
+	switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
+	case ACPI_HMAT_CA_DIRECT_MAPPED:
+		cache_attrs.indexing = NODE_CACHE_DIRECT_MAP;
+		break;
+	case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
+		cache_attrs.indexing = NODE_CACHE_INDEXED;
+		break;
+	case ACPI_HMAT_CA_NONE:
+	default:
+		cache_attrs.indexing = NODE_CACHE_OTHER;
+		break;
+	}
+
+	switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
+	case ACPI_HMAT_CP_WB:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
+		break;
+	case ACPI_HMAT_CP_WT:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
+		break;
+	case ACPI_HMAT_CP_NONE:
+	default:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
+		break;
+	}
+
+	node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
 	return 0;
 }
 
-- 
2.14.4

