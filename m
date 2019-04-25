Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 801C2C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 484D0206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 484D0206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F7696B0007; Wed, 24 Apr 2019 21:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AE1B6B0008; Wed, 24 Apr 2019 21:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023E36B000A; Wed, 24 Apr 2019 21:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF7AC6B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:42:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v9so13243691pgg.8
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=QleL8CAONDSgNNXma3dxkm0/dQm/tc84zMmGS22JMXc=;
        b=PtCFwEbQldCedX70WqR6cJR+8+Aq3E00cWbBlMRgMJwe1mlrtFTtextu4GJ2gTziDp
         +xMxWkQMgF5cUdpMckujUZRmxlXzfwjsjPc218XjX1kbtKGO9nDQJsmlhLHFqRB/AdV8
         SX68jWM3/mVWg7saTBZSKm9KIaYa1HDozeYZk+EXl8wIfARFkzJir4pfkPy/x9yTqePx
         w1YlX/g05oOG6b/oHEthzUXL7jL2WXnRqa8kfrsbhhCJN0EzsaJnRhsg152cIidq/67X
         qWnxHJ6V4/0oXUtxXADsTCv+ypYnrsIfGB5byhLCoyKmWKFqHm75UGL61CajXX7NTV4j
         b3TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVnigoKKUtZcMhRzU7J2733DxWCbnVlCy6cFQc2x00iT8sjuurc
	kyfZtynonJr336PwZ0XkOzVOEX4iSz9gFzvC1LAn1jnHIyxyaj3MvejKAfdUXxtjocXAtNECb6h
	vWajDVQmr1RmzlgIFmZzdeVEyhuFDpdAL/Ne/IiapfAWjgbmgNBKpC/YEFse7cXWujA==
X-Received: by 2002:a63:fc5a:: with SMTP id r26mr31855761pgk.97.1556156566529;
        Wed, 24 Apr 2019 18:42:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/sqK2Vtep0oeGfwD4pr/9Uykez4MffWcwKYD4CKuzjuRaZg+l9FfOQxhyeBB31yGUWJHd
X-Received: by 2002:a63:fc5a:: with SMTP id r26mr31855698pgk.97.1556156565591;
        Wed, 24 Apr 2019 18:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556156565; cv=none;
        d=google.com; s=arc-20160816;
        b=RQUu8fzkcSleuFi3XGtjhduH4GBUw9nDEAlaEDHI9ow7tVStoNLd+2Yc5Evic94zPM
         L40VIzOZuX+zRTQQt6ALtFKVgbUO3JSWw0Pdh5RUnlzRepmVee9SyDcICCqpRX0JUgcS
         0GFMs3PLSvBuNkHkiaBA1R6TOoRcXZzAz8GB+haVjV8HoZDvytaMs9Ptpgo6JqapqdN5
         QObukXMGf/fQrR8Z0K6Fxt/PVHSLYotVilbBLrdielLAwlRm+gA3PPtWmqvVB1s01Z4W
         4KKtQBJVIqzgbDbx6PnnDkfCnFpqJ3V0G8KYXJ1ye8RX130/vVaiT4OOS8dhDNxC+HaQ
         UNUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=QleL8CAONDSgNNXma3dxkm0/dQm/tc84zMmGS22JMXc=;
        b=z22yH1bwVp74WY1ICjGvp/TrtTda/0vAyIl0PIj0WoRjUXMCI+DwKXAirB0YNmHlfB
         GrFkNqzWSBjAF/f692mUOFh35Biz2mohGuR2lBHdaBiL/FG4YsfUUFhbRkwcg4OkjFy3
         HU3XqIP8Lt5m0jX4NozTtHf+KAIsfNk2MUc3Rczjp8oMZkhohw+4o8OUbwxqVJ7C/bqo
         +7pZDbhIQg0M8IFIk830UdKwPvj/FX0tu2CBxVD8mNmJsSztH2V6pY3/UL8Obdarv41x
         3s+phVGKk0PufRB3nQd+Nq1DfpjIslnJRqwwGy5/LN0xNAOFwIJVwXWc6zlhRqlpQwLj
         y2SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si21134661pfc.278.2019.04.24.18.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 18:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Apr 2019 18:42:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,391,1549958400"; 
   d="scan'208";a="152134221"
Received: from zz23f_aep_wp03.sh.intel.com ([10.239.85.39])
  by FMSMGA003.fm.intel.com with ESMTP; 24 Apr 2019 18:42:43 -0700
From: Fan Du <fan.du@intel.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	fengguang.wu@intel.com,
	dan.j.williams@intel.com,
	dave.hansen@intel.com,
	xishi.qiuxishi@alibaba-inc.com,
	ying.huang@intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Fan Du <fan.du@intel.com>
Subject: [RFC PATCH 2/5] mmzone: new pgdat flags for DRAM and PMEM
Date: Thu, 25 Apr 2019 09:21:32 +0800
Message-Id: <1556155295-77723-3-git-send-email-fan.du@intel.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556155295-77723-1-git-send-email-fan.du@intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One system with DRAM and PMEM, we need new flag
to tag pgdat is made of DRAM or peristent memory.

This patch serves as preparetion one for follow up patch.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 include/linux/mmzone.h | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fba7741..d3ee9f9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -520,6 +520,8 @@ enum pgdat_flags {
 					 * many pages under writeback
 					 */
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
+	PGDAT_DRAM,			/* Volatile DRAM memory node */
+	PGDAT_PMEM,			/* Persistent memory node */
 };
 
 enum zone_flags {
@@ -923,6 +925,30 @@ extern int numa_zonelist_order_handler(struct ctl_table *, int,
 
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
-- 
1.8.3.1

