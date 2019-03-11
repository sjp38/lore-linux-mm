Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CFE5C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:56:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 014EA214AF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:56:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 014EA214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 842298E000D; Mon, 11 Mar 2019 16:55:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EFB98E0009; Mon, 11 Mar 2019 16:55:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70C7A8E000D; Mon, 11 Mar 2019 16:55:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2986D8E0009
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b12so166720pgj.7
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ewJqgFUqDpv8Lqv/Yuto2PNWo7oT6nVxI/FcdI99OAY=;
        b=bQYmzGpFByakjg/rieMGCWnS83IKBpp4bA3EL9RtJwnhxArZN37+7tTVE2aqfCX1g6
         SKfeKRVWLyDQQTMPxkkosJiu/MHeC5aNX3ArMY9OdoCknV4sVso7A0SeI8QRMHbKPHrc
         pKc/XVr6aV31Zd93NEOr9feRYx/uq8mMg6wsRpDfOK6Qj4VUWLpRiF9UqtRTWryuM7A9
         jVj1NxDKiLX2BT/upCu/L7wnfTBtXkxHlsBksdvYNV0D1Iruw43V/w1WynRU/O+qWfd5
         UbFgWAkM8M9SbrXlyR+Gwk1aG0jX9wotGvInZTKhP0e97uUs7+ed7UHZQ3Y+nbICc3/W
         ryMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVJ5zcMY2Kqld4pgdcIBSISE/FZ3ExrNx+Qt/OKun/MDytRrZzr
	NhnwqHLz+BxKh5oJ58EHksfBNkeONamzBPiHkjXjiT+pOAVuSzpJC0DxsykzkTqsBeOsse/qDSl
	F/7yye2wK+TmYJdhcEvSS4KbcdP/w8EGwZIIsNuIjUjj0LXRKXDUAYgUNr4wBENBHqw==
X-Received: by 2002:a17:902:4181:: with SMTP id f1mr36340728pld.280.1552337750850;
        Mon, 11 Mar 2019 13:55:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkhioyz15OthJELyfR2DDInXBKFVgNv3iYtOROHIB9VcvOWHtNXxHyFnyLGNSB4uJYT60K
X-Received: by 2002:a17:902:4181:: with SMTP id f1mr36340348pld.280.1552337743684;
        Mon, 11 Mar 2019 13:55:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337743; cv=none;
        d=google.com; s=arc-20160816;
        b=hDx0gVVShuWmlM4ImlJJJeE2V8ZGnwf6bqfcAvpDUm2Ga9vSE37N9jMTjWr3sTMmpC
         ZG5VjCR8SKBLn84ForNMIFjGaGM3nBQSITCZbPEIU9IVHF+i5g1utXfmGdvn/ORjquc5
         0BGGfszUuvLER1QScHNKx67DJPsprY3k/KYy4RcwLdIuuhErIFVAjpJAtP+wmU3D08DU
         fXQUE8HfkcRjYGqTOMG5UkoMsscm36R4ZLFkXSx/5NAPczuJygIkAlmT9sZJQ+Dnujy6
         BCXpS1/mVj7W1+TLUQJRe6q/SPmxGZbqjU4nLP9QUNdpz611Lz+y5Kvg/TCXzj82QpKE
         oPWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ewJqgFUqDpv8Lqv/Yuto2PNWo7oT6nVxI/FcdI99OAY=;
        b=YpgY70NDzaiWJOPplKY4ZTeNeR1L5khl9Dq+5qlmOaarNMc1uY2/ddFNDOdVkz3dyl
         M2oKzSHMV4vPOLDbDzaJRxklbwBb0mudqmpsc46tYIQqiLK0gDMh5jWx+F3iwfGUXFb6
         mAMlSThQCm7PbtXn+WwVBqKplzeouWnpYRSbPkZuGgANdZmvoonhsbTCJPg9uENqKo8q
         jWefOIbjWah2btT3a29zlwedkxJ68Wx61nRuW+pu2Il7vioNbnEMzVrXEQS/bTA2pq5c
         wv4s2qPxsIk5Y4Coz1E/gbcCDIYgH6Co/XxW/pTD29WzRgDT4e5MUMgSyxeI6imwWb87
         xOag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910190"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:43 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv8 08/10] acpi/hmat: Register performance attributes
Date: Mon, 11 Mar 2019 14:56:04 -0600
Message-Id: <20190311205606.11228-9-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Save the best performance access attributes and register these with the
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
index 01a6eddac6f7..7a3a2b50cadd 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -545,12 +545,20 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
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

