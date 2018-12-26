Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAD98C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 935F0206A3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 935F0206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 831CE8E0007; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AE7F8E0009; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BB698E0001; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA73C8E0005
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so13962427plb.17
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=c+luLYTm7+SGMH9nIfj/WGMlXDxTm0Th3M4ATYUWmYU=;
        b=JxkGvE51lkX7uiNGatOx1Pax1t5cnAlRoTJ9ePwInaOQ10i2dNpqOc9Vs51neB4r3I
         spDiMs9+c6f7XMfM+DPjuAag/paXwI+PyZujRMW5qZeLVBHfrY2/r+7+3XMT7oIOMy/C
         Uyzrdi4YKeLmXPGTwZO+BORR40hwFtMQzJzh09PhASJwxemjs1o24aj/a2FXntGNe1wr
         ng6CWp9P7pp17Vg3eCJ29WI/C7MO3lJ10AXuBEhPt77TRZeRFugGIpHGeGAbJt7QPnhA
         HGUM1wwQEa0SnGYuhyPNNubND+pRooTe9Fi4D9UXIIn40VwNfdvGHSn9HMiGfYFSAFwh
         DyTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukc+wSGW/4iQrsBk7vAVSu8G/78m1+2lZC2a/GQtE+OyUkaPiJpr
	f3Hi0j+wz/hZDfPj1SchkiQNOSBwsUUXhnZLc5ethgc3oOd3qmEGWEEBGx/nY2oGyW56ydtTOVJ
	MG+wv3E4OXP4IpdpED+bP/O4eMM8Rdyp7DCbD20fJ42wMLlQ4Kri6c+G3X5PIxqNYXw==
X-Received: by 2002:a63:2507:: with SMTP id l7mr18218225pgl.22.1545831426590;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7vX3YI1BqvnbR/LiYn2RBWA7tUmfku6awpxon3tbxaUZ8pUdg9P8y10BdR8EzSjh23tgeo
X-Received: by 2002:a63:2507:: with SMTP id l7mr18218194pgl.22.1545831426102;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=VTPx/xdo7DY1FdPAEl2ojtcfDXC+biDQaw3tVtpy05xfiNyQ+jRRTHGKAV4mMPb3W0
         SYDC2wAQBJemshkfdz1IB1KI72iniw260GX9P3UcgNFs/349xmlxna7mR5cACFan+1Ic
         ubmGUo9X8bIMtuOLlLH+UIyJcXDzos5uCvFH5HCpgRkCFYctNkNHCGtUAgURtIYRFjCi
         6zxOs1Ypa6qbQKtIElN49zoAttQAv7VTDJi67PJ5I10TXNWuK5MM3wYKq3iTsNr+qIN8
         4jIWEhbnYx+auMvy/tCdzyyDWl3+yqA556L2ce8DMsKPKVQ6TlKRPtNSPWK5nPHFvz5B
         BYAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=c+luLYTm7+SGMH9nIfj/WGMlXDxTm0Th3M4ATYUWmYU=;
        b=bkA8ZYobR6SPgaLj7YLhh7PISAyV0G7tWYeQfPK4ooTt39gK5p8rhV7YRle+9zY1y3
         /n9Q00D0EuvXOV7K5a9fT4DhC0SfMEXuVeZh8lWjHGG3H12EizW9E14mHS2Sa6gUEqan
         CT21a+9c2Cm0Ii8l1QdkX1YwXJR9+0Md/BLgIKYa9N3+xTaI8asy27c1WFt3nBeObIaI
         7yH5bFpf94H7Fo+mU/xV4ZCWU3mVSFDRgfXSqGeYd3iiN9v8aEZeoKUqnREDjGCeBOg3
         dI4Ce8EvGTFMYbmNaZ4Kv+Hkle3qMI2TqZNj0lMxjDIpVWC4nkTUg7eCpAvz2okYiIhN
         vhMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358927"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:01 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005OB-9m; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.348801665@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 05/21] mmzone: new pgdat flags for DRAM and PMEM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0003-mmzone-Introduce-new-flag-to-tag-pgdat-type.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131451.N--rsCQsStK9vNVfiCChXb1MXqqFzH89dsF-cmuPObE@z>

From: Fan Du <fan.du@intel.com>

One system with DRAM and PMEM, we need new flag
to tag pgdat is made of DRAM or peristent memory.

This patch serves as preparetion one for follow up patch.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/mmzone.h |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

--- linux.orig/include/linux/mmzone.h	2018-12-23 19:29:42.430602202 +0800
+++ linux/include/linux/mmzone.h	2018-12-23 19:29:42.430602202 +0800
@@ -522,6 +522,8 @@ enum pgdat_flags {
 					 * many pages under writeback
 					 */
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
+	PGDAT_DRAM,			/* Volatile DRAM memory node */
+	PGDAT_PMEM,			/* Persistent memory node */
 };
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
@@ -919,6 +921,30 @@ extern struct pglist_data contig_page_da
 
 #endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
+static inline int is_node_pmem(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	return test_bit(PGDAT_PMEM, &pgdat->flags);
+}
+
+static inline int is_node_dram(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	return test_bit(PGDAT_DRAM, &pgdat->flags);
+}
+
+static inline void set_node_type(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	if (node_isset(nid, numa_nodes_pmem))
+		set_bit(PGDAT_PMEM, &pgdat->flags);
+	else
+		set_bit(PGDAT_DRAM, &pgdat->flags);
+}
+
 extern struct pglist_data *first_online_pgdat(void);
 extern struct pglist_data *next_online_pgdat(struct pglist_data *pgdat);
 extern struct zone *next_zone(struct zone *zone);


