Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3727BC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 05:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6A96217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 05:13:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rIMwM2ro"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6A96217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74E9B6B0007; Thu, 25 Apr 2019 01:13:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FE816B0008; Thu, 25 Apr 2019 01:13:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EDA36B000A; Thu, 25 Apr 2019 01:13:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 293CC6B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:13:49 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j12so7025096pgl.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 22:13:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=A8io2vWFKu5lSiWar06Xe80lZwFq0HaeVGqBJrIMHbY=;
        b=aecKU9LVwL/fT4awGzGc7ASe7ylwWw0EdERu/1jSBA7slFsnXSobQIM8a6/Yllm1+g
         eExNV/Uv3wYsWYQwrfaWZqUDe1ERlhUyKcwSnXWOls0kvMYzqRHk/6IpE15S0gtagXgK
         rP0X/ng2pq6sGzyL3ZRgNeMXh0KA+awdyZDhf+76oIDQUvsL5udL9eyuURLgLMPG9gM8
         NvlTpLLK5ppXXo9VjhHLbUTaqPO8fgbrFHATUwJ9N7w8GQMK9vghr9p7M6s+FGknAtWj
         2rGczeNriz7Xf4P4V/hKRGSV8tT1pJhYFIshGth5DnmLkz8ZcaYs38bLMvODo+dIt463
         joqQ==
X-Gm-Message-State: APjAAAVXgtcs4fHjA+tEFxy9un4xapHiFsArNvu4B+WNXOU0HwpM7QwM
	rMF/eoLnuoEBGDneuCNBHssQtwHO5z7Bs3shbUwzTCiSO900e4NtNynRVzNX3KxvF2CkTJ3tUd3
	L0SFvYgssWCtKo4NwIwNzCDVzXDRlLLQKxE2xLThiCJ4YCHCcNPrk9R/u74aQQmYegA==
X-Received: by 2002:a62:47d0:: with SMTP id p77mr37136170pfi.95.1556169228195;
        Wed, 24 Apr 2019 22:13:48 -0700 (PDT)
X-Received: by 2002:a62:47d0:: with SMTP id p77mr37136073pfi.95.1556169226971;
        Wed, 24 Apr 2019 22:13:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556169226; cv=none;
        d=google.com; s=arc-20160816;
        b=qqkdFzAFsxoCAOZnD9eLmZPOnNrqZM6MLykEpIbVGQ8Ln1d320xwYgcO8aK3Oyxdyr
         b0dcQ9KNPUXRlNUSuRxTQTqccHM5dNDuqU1g3U89syCB1QzuPPrM4y7E5VtbQBhTI0rr
         7KblMrDag7gtby1Hj75wXInlqhjedBS2xxfq5XUO9xEOilxqj/rRG9wpcywVXVKOqd8u
         zWv8yMDVo30On5IcJtHaP7YtX/F3SpkgdSAarn2/vDWb0uFPe9DHe7DP2V1wNvFr5ZIf
         gB9QGPQtwdtSCYQsVAJKgBQX+6kfoE0JlKvut69YZvmsl521Pk09lCOEKEPCEanx+jkQ
         3S8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=A8io2vWFKu5lSiWar06Xe80lZwFq0HaeVGqBJrIMHbY=;
        b=dwRwOEpNRZXuIZkY60kdMTaBjchQ/psgUECckvrufRcOdi8uKuzLFKTTOC8VsfmnZP
         aG949Qe/+tekKP2g7ZiuAmIi1G7PUONy965cEGaBNjGVnAoU/QD4NGcMdg9UO5Jhfjca
         26gUd1vMvkJwQvUxjrMBESK5uerzBHszls5wo9BK/yAil79eJv17XKR7/KUVDb7yQcQW
         KmIAVlgvBxJJecYRkuhpX3WcHsPozgohKDPIQ532EJDyTW3QNJtijprIPo7dxVLo4Ghy
         7hZ3kPeE9hg2JlNU8AkTZWFdt0/KAyKoSTgdrRIeddgbI6O0Lq3KtHCewSUQnIL2pf6/
         IB1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rIMwM2ro;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor8213962pga.28.2019.04.24.22.13.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 22:13:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rIMwM2ro;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=A8io2vWFKu5lSiWar06Xe80lZwFq0HaeVGqBJrIMHbY=;
        b=rIMwM2roMP5wQd3x+4LAzNc1V/1eC48DZyWzDM2OBLnclVP3lifOwmbv+NP8zBxu7p
         NjOiIl3nj8eyOOgzFPfm2GlH85tKTs+7cVhyxJTFwQEZoUZLAHFsyaKgXOXSjYIJQ/Qn
         czztyvN5639E/4iQLZjNS10GcOf4GABcsdSUNJrypwioJPxt/VrwSxNQMA75eo+O4iIy
         FZo/9pgrt8Gam90DIBO9R1wYj5/dSA3wriW2uMirZ8OWJg5D7uw85H8OwzZCmBn1vLa4
         LlcscLOOVhTEUuvMh9aNTDVZBDUAUvvRBwRvQPoENmIschLqwB7/R0SjmAWSf78Dp7k8
         scmw==
X-Google-Smtp-Source: APXvYqxrJMqcuE49i2pPLtaiuqRFXwVZY6uIhda7Gtt5PG92xTC5DPGWp2or/ePy26UlKwNxRcQY2Q==
X-Received: by 2002:a63:5715:: with SMTP id l21mr7190062pgb.279.1556169226468;
        Wed, 24 Apr 2019 22:13:46 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id n26sm37408045pfi.165.2019.04.24.22.13.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 22:13:45 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: simplify trace_reclaim_flags and trace_shrink_flags
Date: Thu, 25 Apr 2019 13:13:23 +0800
Message-Id: <1556169203-5858-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

trace_reclaim_flags and trace_shrink_flags are almost the same.
We can simplify them to avoid redundant code.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c27a563..57f7923 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -27,17 +27,11 @@
 		{RECLAIM_WB_ASYNC,	"RECLAIM_WB_ASYNC"}	\
 		) : "RECLAIM_WB_NONE"
 
-#define trace_reclaim_flags(page) ( \
-	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
+#define trace_reclaim_flags(file) ( \
+	(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
 	(RECLAIM_WB_ASYNC) \
 	)
 
-#define trace_shrink_flags(file) \
-	( \
-		(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-		(RECLAIM_WB_ASYNC) \
-	)
-
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
 
 	TP_PROTO(int nid),
@@ -328,7 +322,8 @@
 
 	TP_fast_assign(
 		__entry->pfn = page_to_pfn(page);
-		__entry->reclaim_flags = trace_reclaim_flags(page);
+		__entry->reclaim_flags = trace_reclaim_flags(
+						page_is_file_cache(page));
 	),
 
 	TP_printk("page=%p pfn=%lu flags=%s",
@@ -374,7 +369,7 @@
 		__entry->nr_ref_keep = stat->nr_ref_keep;
 		__entry->nr_unmap_fail = stat->nr_unmap_fail;
 		__entry->priority = priority;
-		__entry->reclaim_flags = trace_shrink_flags(file);
+		__entry->reclaim_flags = trace_reclaim_flags(file);
 	),
 
 	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate_anon=%d nr_activate_file=%d nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
@@ -413,7 +408,7 @@
 		__entry->nr_deactivated = nr_deactivated;
 		__entry->nr_referenced = nr_referenced;
 		__entry->priority = priority;
-		__entry->reclaim_flags = trace_shrink_flags(file);
+		__entry->reclaim_flags = trace_reclaim_flags(file);
 	),
 
 	TP_printk("nid=%d nr_taken=%ld nr_active=%ld nr_deactivated=%ld nr_referenced=%ld priority=%d flags=%s",
@@ -452,7 +447,8 @@
 		__entry->total_active = total_active;
 		__entry->active = active;
 		__entry->ratio = ratio;
-		__entry->reclaim_flags = trace_shrink_flags(file) & RECLAIM_WB_LRU;
+		__entry->reclaim_flags = trace_reclaim_flags(file) &
+					 RECLAIM_WB_LRU;
 	),
 
 	TP_printk("nid=%d reclaim_idx=%d total_inactive=%ld inactive=%ld total_active=%ld active=%ld ratio=%ld flags=%s",
-- 
1.8.3.1

