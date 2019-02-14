Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39D83C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02610222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02610222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45E288E000C; Thu, 14 Feb 2019 12:10:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 438098E000B; Thu, 14 Feb 2019 12:10:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28C438E000C; Thu, 14 Feb 2019 12:10:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D25848E000B
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i3so5275699pfj.4
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DdWc0kZ6Cc9d//a4MBx8Xml4gozCc9p4ssV3CzG8xAw=;
        b=XPaZq++cQn4wLGrLvD1OzCqOQmVAo9Ih3dUkmqTxPlcWpNDTmTyt0vZ2NxOseeZK5P
         P1aJp/ODI+aedLcb4s9N1lq/DcknehmIQEqgda5sCejBDsKsXDCx4/lgSV858tQn1y9A
         GH1dUQVqMYvnq5FjtkB3uvTKL7PSiJ8+ceviSblafRy48tKHiB1nnROtKAQkvZAgFkh8
         gYkXBDnOg1sIDOo/3nCOdE88dXtqbRpRZKedtFiqPEaFHG4YjtnAFe1rnAUcda9kop1c
         ZHOOC6eVsKSZT1IooXrysBuj4MpSU2yIWzpuvauYcMW3zb0KtKG6SPsVKI6j5w59RMqW
         0r+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYoReL8apEsytlH0xlN4Pzv0LfU0T/tCgat26ybAkODk8w007+5
	F0OJdi6PB9syRm9PgUn9DEjlLrRP/NNi+sagQm9wtnhBWw0wdCBb9XwoxGK8ZrZiv8XftG/eT30
	t05h6ncyqUL43eAqkIwt8MviPnLfTGTVfMCHRXK7ieTguiTfV0QyQsQK1VrztE46pSQ==
X-Received: by 2002:a63:555b:: with SMTP id f27mr855768pgm.313.1550164245519;
        Thu, 14 Feb 2019 09:10:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia9sP8HIXIPtIDJhTFaJ4COEJ+f/RtY7EFCiro0nT2qFUcR8G72zxcYoQWk5hRA97Ibl290
X-Received: by 2002:a63:555b:: with SMTP id f27mr855689pgm.313.1550164244439;
        Thu, 14 Feb 2019 09:10:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164244; cv=none;
        d=google.com; s=arc-20160816;
        b=eMoOumyOqji2nWXat9wwYRy6etXFz2gusYq02GkuoCp7U2CsD0lsuEJ8+IUjWoLzvV
         2FPPrKZN7qa1wc0lwy60QOAMbsX2Wb/zYIkMGO9ZR9aeVYRAzHQF2rvthMSSN1KQpKR+
         hw6uvCXl6zRH4T2PnqbvpgPhGb/VsS+CfwxCmqJD2XuVpLEEiJ29G6e10k6Rd1AYUV1N
         5cqmdIWE9V44tiLQWKWSGGwjuUEw3hEaEPJHGbL/CX0qgXd4w5zTkEPhbBoZp3/O6+sk
         kDwuG6etYh3IiA4VvCoVojnW0cGGQzwWx12aoBrkiHkTPmPnMC+yYty5Tp6XGn3DJTYg
         IEMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DdWc0kZ6Cc9d//a4MBx8Xml4gozCc9p4ssV3CzG8xAw=;
        b=aWZQZ2ze5Ff/FLiJ3rzVi3lm2p/ogldv5+FLjoyY1cXXl0BCVrF/1bVbIjxpzkwjFY
         ofSZijtb4JY552Ytf/mdXwf5s5We7xoJH6GOPm17myk7wFrJjz/4YHne3aIr4+HGjPaz
         djXbnFYQd0kbkythH34vS33hVZvn5dwBF4d96Ln6TBsWjXxvcqUAS2yZZvdM96YCI72R
         En2Fuoo1WsVhT/cwva4HhS24jJLg8lUoxjkDhWCFowSikmqsjlnQolJry2IA0C1dHJJm
         GOvYPccV1ve0rr92c9+vWJYj56uRpKtSCAmAfEHgvmJwlN1YlXoONw85JwGn8091AbwI
         ITXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:44 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:44 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613137"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:43 -0800
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
Subject: [PATCHv6 09/10] acpi/hmat: Register memory side cache attributes
Date: Thu, 14 Feb 2019 10:10:16 -0700
Message-Id: <20190214171017.9362-10-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Register memory side cache attributes with the memory's node if HMAT
provides the side cache iniformation table.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 6833c4897ff4..e2a15f53fe45 100644
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
+		cache_attrs.associativity = NODE_CACHE_DIRECT_MAP;
+		break;
+	case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
+		cache_attrs.associativity = NODE_CACHE_INDEXED;
+		break;
+	case ACPI_HMAT_CA_NONE:
+	default:
+		cache_attrs.associativity = NODE_CACHE_OTHER;
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

