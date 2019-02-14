Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51178C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F264222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F264222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 940298E0009; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EFB48E000B; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B5C58E0009; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38D908E000B
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so5257218pfe.10
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=jPUbIWuBpn9D8LXQT3Zb7r/0pf0K4Uk+RxabChdpc14=;
        b=kjdJXB4jkh0bzWMpZEdV3kJZL2nI8HiNZo92hjfYbKRRfZehA5NA7bIOgNq2pVAMRC
         7UlulFYlrxDny9usWGAgBhRvKNqmxyRMb71AXzxwe0tjWtNmWahPI4SZuR1hSSICNTDs
         dTc54wCSar2aol+iygPk8u1vcWd60R2wuhxOnbhrOlYO7L3zKXK5mwvoa0V6TY2vLCSV
         vYx0E1k9S20bHvZl7M5vHgAu2sqIhX5IAfdt+jJ/Iu8gb10fTmAHipvr7Fqb2nPUWiaZ
         Gb2nBGD4Khoekb4lwqkRrIct6pyGt6aZAzbkkJjgzlBhE7TmGNtg/zmV0MA/ppMF6Z3M
         tQVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaw9VS+7yPjxvyscL5pDYAk+cSdRc1M1MeJIEpebnEoKDGh42CI
	UxB4+xj0tan59iWsAQTvYtp3/1CugpF0oYJzVt2YxMG820a3A+6yKjRbYVbKYUcrI9slM9/uDIN
	gH1WqTRNepdrFFNyPzKoBMBL61UClQQvgefyZDQf+K+t+myKFhI82LNnvKhCHnmZalw==
X-Received: by 2002:a17:902:7896:: with SMTP id q22mr5330188pll.280.1550164244920;
        Thu, 14 Feb 2019 09:10:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY3bVFct7oMwm9ckOMQQ5AAZlO8UHPg/DuNND5IRnA3o6ebbZ1OXaxeAdGl9j+4iWe31TMv
X-Received: by 2002:a17:902:7896:: with SMTP id q22mr5330112pll.280.1550164243877;
        Thu, 14 Feb 2019 09:10:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164243; cv=none;
        d=google.com; s=arc-20160816;
        b=vrV+lwstK5EiuAFZuBwvJ/DPzxpm+g03d/OWiptF83D+fh7hAhFe6a2wB+yF+gQxe+
         KlkA4i+PSZWQn/dVA7CLGaRadGeO98aDpa0U54iKA+pT04IdYmlDYWS5IYDfuyRCCiXc
         +LpM4/uGJFdrVR7AAhp+O0bhGHut1cIkJEreiB54m/Lehf5DDYpJtciEWnKmXmdrlKNM
         x9H7yheZ0rtOqN8ALqyUIJnpe/Ckt/Lukuld6pJuTphMEsIybfXUzBw9LnTvwK4kMECJ
         6ZzQMtDYrt/XeVSGSlqeywgODtKeSv5qFMfSY/p79P05NpqbLtm9WbIIt6L3T7PHswRh
         KwLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=jPUbIWuBpn9D8LXQT3Zb7r/0pf0K4Uk+RxabChdpc14=;
        b=eT9rA4TeITEeM6sG5+Gh/6VokTvUVwHqWNXJAjNg63bqNKzPyCxzQ+foPimvKT/TCN
         BtwmXSvcht2uZTMSvxt9QSGccBn5fU6iYgAjJ/qgApZAtlNYzA4mdVOsqLb/sl8f/GQQ
         GyPChQd59FFks8p9ejm2oAmS0rfLVaO5JhTZz2pHZHCQYspxbDVb31r/ddeSIwzT2heK
         dd//OpZ/nsimWnvDyqY21VNzU6G4co4V2r8w3on3GIV9pYPv5IdcDdaAVDZXlzuyOrap
         DAvZo2PvP+iW/8vSCmqFQh6xpLbXJspEeZSFIeAslKD6Ngx4j9h0mcCjtfM88RsSnT0o
         cWJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:43 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:43 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613134"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:42 -0800
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
Subject: [PATCHv6 08/10] acpi/hmat: Register performance attributes
Date: Thu, 14 Feb 2019 10:10:15 -0700
Message-Id: <20190214171017.9362-9-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Save the best performance access attributes and register these with the
memory's node if HMAT provides the locality table. While HMAT does make
it possible to know performance for all possible initiator-target
pairings, we export only the local pairings at this time.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index b29f7160c7bb..6833c4897ff4 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -549,12 +549,27 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
 	}
 }
 
+static __init void hmat_register_target_perf(struct memory_target *target)
+{
+	unsigned mem_nid = pxm_to_node(target->memory_pxm);
+
+	if (!target->hmem_attrs.read_bandwidth &&
+	    !target->hmem_attrs.read_latency &&
+	    !target->hmem_attrs.write_bandwidth &&
+	    !target->hmem_attrs.write_latency)
+		return;
+
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

