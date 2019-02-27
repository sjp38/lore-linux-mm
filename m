Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FFE2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D843F2133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D843F2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C046C8E000D; Wed, 27 Feb 2019 17:50:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB7E38E0004; Wed, 27 Feb 2019 17:50:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2F348E000D; Wed, 27 Feb 2019 17:50:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECA78E0004
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 17:50:36 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id f10so13475816plr.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:50:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=7Kvu3Pt4lGB8xApQX5Now06Jiasc8XtxmSQBuYXB1Sk=;
        b=lg4TfG3N6fgY9F2JAqbabzQp3B8o+gplUoPYGiLJhiaIUuvo2zyilI6FveD06UcB6I
         jY8WMPabxt1pD/zvSdwZsr44kp9hN3eIWiRSJTUlrZQCvF9p1s+quBmuvJJFO4B38RCt
         MEUx3RTKMQ+m9Cikks2Re4xcgduTkA3+Vdgjv58CDMgZK+f3mpYzm/UDf2+WNBTXoqQZ
         p5jkaBBdmAF2B7lZHEB9IMyet1qEQvHXJHWGHDtKJgzpC46OURJSN/BQ0TD+jXc3UYit
         vn5ZupZ5LEmWWZlEbIPc/FHbvB8yFZgFicbzi6A25IQ40V2nd7XYYeEekDfWx9OJS2Jb
         yGQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ+lxmOVY22KMdOjJ1aeFLB0X8D98KJOcD4jBjms3WzQK4EL6+v
	WJZdFHV0Q5nrPN0GKOAvws2QApUO9fmRE3kEaLjgRY/wcvkWBY4OBbJkc4WW94B/pVamXz8Xtne
	NRaToNfG5zoyG0OEES+CM2Wo6Wcw7bSVrB+q5ITqBFOG/docPg0AnE9MPG5Ks3GW3aw==
X-Received: by 2002:a63:1a25:: with SMTP id a37mr5489621pga.428.1551307836048;
        Wed, 27 Feb 2019 14:50:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib10yt62+HSza1SZfu0mO4fnQg1ESKf/o+uMOWna1QWNHMYiGkcjT1oKRw6EqkwkILpPIcv
X-Received: by 2002:a63:1a25:: with SMTP id a37mr5489557pga.428.1551307835193;
        Wed, 27 Feb 2019 14:50:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551307835; cv=none;
        d=google.com; s=arc-20160816;
        b=U+O4mu8tpr7ixyMtPfQQS7i4/vcoZBjaJ+bRhalXA2nr99EsduXB5+4YngZdjuFR6u
         pmEWSMbgTAk6FE95bc9npB2MX2rcuaKTsPCmMpYOcoajhbz2xr5tB//CGQHnkfKCfSCz
         NXIFDgHYYBpMOBraoGt5B+4j2gJYeEwPC5y7SJiH9meqZ0w2Nuh9akylLw9nhbBc5QPn
         DsncFmXKfz3BvpTODAAMdgvxEKEPuXSNr0jnssHhdsxLrpBuc4bQsZWhEB1hFhBl/s/B
         Yql6R63qEIB2Exz4hXNCWWhlv4qWVqDooClsinV7QUO9SO1ByJtbg6Kj+GBKnovsW0co
         hisA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=7Kvu3Pt4lGB8xApQX5Now06Jiasc8XtxmSQBuYXB1Sk=;
        b=PS1lM9YLLbDce3vJcAp8jN+0npYIO+vq0yqTVDyfZ3iZsD61yG7xoUHea7RoeiXX3C
         VER+NM2n5yq4QR1xqRkn12ZUrEOODUaz1UGepovTfWuy6xJWeiHX7lUDT9HW6lewgwAs
         h5cQ5hMtQkqD1z5HxANr6uZwHnFbD9Ejv3vl9tFtLjT6Ezvp474MD7+l8DBwlACdePaX
         Ncilhxgwk/szLc7Jw+LK+RKRZOr7dnKmxp53N14ZCnsMD4V6HtVF8kb6nBRTQv9mi25q
         pvUax5JJKKGHWBYtI0KCltPG3tbvBNS8hdjbXe2rRt4v0qnPXLsnoLGmGn7Rq7F3PsSO
         J8NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z20si10836901pgf.324.2019.02.27.14.50.34
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
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 14:50:34 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="121349425"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 27 Feb 2019 14:50:33 -0800
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
Subject: [PATCHv7 08/10] acpi/hmat: Register performance attributes
Date: Wed, 27 Feb 2019 15:50:36 -0700
Message-Id: <20190227225038.20438-9-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190227225038.20438-1-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Save the best performace access attributes and register these with the
memory's node if HMAT provides the locality table. While HMAT does make
it possible to know performance for all possible initiator-target
pairings, we export only the local pairings at this time.

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/Kconfig |  5 ++++-
 drivers/acpi/hmat/hmat.c  | 10 +++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
index 13cddd612a52..95a29964dbea 100644
--- a/drivers/acpi/hmat/Kconfig
+++ b/drivers/acpi/hmat/Kconfig
@@ -2,7 +2,10 @@
 config ACPI_HMAT
 	bool "ACPI Heterogeneous Memory Attribute Table Support"
 	depends on ACPI_NUMA
+	select HMEM_REPORTING
 	help
 	 If set, this option has the kernel parse and report the
 	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
-	 and register memory initiators with their targets.
+	 register memory initiators with their targets, and export
+	 performance attributes through the node's sysfs device if
+	 provided.
diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index bb6a11653729..5b469c98a454 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -549,12 +549,20 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
 	}
 }
 
+static __init void hmat_register_target_perf(struct memory_target *target)
+{
+	unsigned mem_nid = pxm_to_node(target->memory_pxm);
+	node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
+}
+
 static __init void hmat_register_targets(void)
 {
 	struct memory_target *target;
 
-	list_for_each_entry(target, &targets, node)
+	list_for_each_entry(target, &targets, node) {
 		hmat_register_target_initiators(target);
+		hmat_register_target_perf(target);
+	}
 }
 
 static __init void hmat_free_structures(void)
-- 
2.14.4

