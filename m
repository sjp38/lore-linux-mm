Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F1C6C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEEB421738
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEEB421738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E347F8E0005; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1B4B8E0006; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEB278E0005; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 811DE8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x23so443458pfm.0
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=fMv/6P4dkMu7f+BQbRadexO0PfDerpth1q2Z9fsJHNs=;
        b=rCaKcdsYIw0NTVemQskgeteYkj0e7bvbVK6Vq9xcbJvSBuTLzkzNgCurTmHn5ATMbe
         YqJmX7aNIjDnKqtccaM/+HGMLsxFK82BjssCvFt3C2vQXnBtE1tzkkcRRm9WtzX40pio
         VhH1KfTFGiBAeFrPibSr/pvoXbGycyGX9x722cIXy8Q8ynpjPNdDCpb0EQJPTACYO1qr
         fGOZ0xOO7maBOEElezqTlJokxmOfsU6ei2SI4c71ylvcngOHOCNoIuPJ/jRw37JcQY/b
         5oqow+8uAvndPkjfn3jqQ+jnP6c9ArCQiNtUdXSjvADCJcW40bZJ6aEVqFCy6Pbf0iKJ
         vWOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCXt7xVONuroqGupCrpAycgphiZDrW4W+TQsRb67y2LK+u26hG
	9RadG0eac6+YFRn/3DejYz0MtiToL4WfS35qb9DmHsCioLeVF4LpDtbWRGgLnXwdAU1Yo9uGvjI
	dCq9IaFDN7h0diDifcJ1nuzM+AkCgGoQwFa86y/ORe338SvVepcWewhSYaIgOa/NqRg==
X-Received: by 2002:a17:902:e85:: with SMTP id 5mr36187063plx.13.1552337742203;
        Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtBCRaYPBMcPCSAgqPgiJKp+GVhzuLOZ6zdBlJrsp3a3Pqq0P+116Itt+OYEYs292Rgzbd
X-Received: by 2002:a17:902:e85:: with SMTP id 5mr36186982plx.13.1552337740753;
        Mon, 11 Mar 2019 13:55:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337740; cv=none;
        d=google.com; s=arc-20160816;
        b=yk20MTz/ieDOlWH6m/I9p8PMC5pocXjTR9SAUdKxyO8tGOrafD/ZjOFKkqdORSBo8J
         4g3bkg+NxJkS9BP0EvtWZkpzFnaaEcBzn/UTwV3vmP6updWbWMm2LGSGX0hNbU4q0OtQ
         XiGrQ00pWWhnzAGGjrlhe7+XAG130kMgpqm2nU9/WQ0QxhogYRP5NzsLcS8FSCrq4rN2
         tTofSpqL238q7sV14HMCRt2mVKTA6mIOi2geZL6WaMWTIMF/dAOT6atrnku17O3S6wi1
         qbnSHCXCYNuWxSBymk5W8bJpUiQqMtWi6suXZ461Jb7rt0xHhLJO+XGFDqlDOzkblj3n
         dTQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=fMv/6P4dkMu7f+BQbRadexO0PfDerpth1q2Z9fsJHNs=;
        b=n4lmH0Hzb7oY+wN4I5wyluJYaUQs6GPxKz3jW2NsqgOc7VXFFGOd5I3g6aUrgd1/Pm
         jXnYw3h0rPjYm94YPxOhI2vTnv/nviFnfXaJ+UWRwZxUzdhc/r35kytBzBwqRd+CbSx1
         F9gREDV/Nj8i9vlzvm37r9GTHt48Hm25jXI00vVWdYUVNVrN/AmN+kEe3ZxxAhp0ytKq
         EcHI9tgCeJYPeKFmOwCCrhd6QDiL3xs49Uqy6/G/6NqNcMF8dSvILqHFC2bsXZbTaqgG
         n3JJyFvsxcDvdkZNcO2EA2Z214tSz6MBh34xOVY0ZZV814nnpXFID/WQQ3yBa3J1KTl6
         VkBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910159"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:40 -0700
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
Subject: [PATCHv8 02/10] acpi: Add HMAT to generic parsing tables
Date: Mon, 11 Mar 2019 14:55:58 -0600
Message-Id: <20190311205606.11228-3-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The Heterogeneous Memory Attribute Table (HMAT) header has different
field lengths than the existing parsing uses. Add the HMAT type to the
parsing rules so it may be generically parsed.

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Acked-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/tables.c | 9 +++++++++
 include/linux/acpi.h  | 1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 7553774a22b7..3d0da38f94c6 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -51,6 +51,7 @@ static int acpi_apic_instance __initdata;
 
 enum acpi_subtable_type {
 	ACPI_SUBTABLE_COMMON,
+	ACPI_SUBTABLE_HMAT,
 };
 
 struct acpi_subtable_entry {
@@ -232,6 +233,8 @@ acpi_get_entry_type(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.type;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.type;
 	}
 	return 0;
 }
@@ -242,6 +245,8 @@ acpi_get_entry_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.length;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.length;
 	}
 	return 0;
 }
@@ -252,6 +257,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return sizeof(entry->hdr->common);
+	case ACPI_SUBTABLE_HMAT:
+		return sizeof(entry->hdr->hmat);
 	}
 	return 0;
 }
@@ -259,6 +266,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 static enum acpi_subtable_type __init
 acpi_get_subtable_type(char *id)
 {
+	if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
+		return ACPI_SUBTABLE_HMAT;
 	return ACPI_SUBTABLE_COMMON;
 }
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 9494d42bf507..7c7515b0767e 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -143,6 +143,7 @@ enum acpi_address_range_id {
 /* Table Handlers */
 union acpi_subtable_headers {
 	struct acpi_subtable_header common;
+	struct acpi_hmat_structure hmat;
 };
 
 typedef int (*acpi_tbl_table_handler)(struct acpi_table_header *table);
-- 
2.14.4

