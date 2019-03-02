Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98B90C00319
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 04:39:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56CD02085A
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 04:39:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H54t1Lwp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56CD02085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E999F8E0004; Fri,  1 Mar 2019 23:39:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E480B8E0001; Fri,  1 Mar 2019 23:39:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D614C8E0004; Fri,  1 Mar 2019 23:39:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9536F8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 23:39:30 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q21so20463481pfi.17
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 20:39:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=T80MdXzCnVwzBeJXMQTkL4J5G0aH3MXHjAFEpqlA0WA=;
        b=oQobE4B8XhjSULp74xIS08CmY2eFjnMwjj0xjflAW83vibzvj4t8jUCiTMIZ3t1x87
         ts5+QmaFsjMW1U5wVKSbLUK+fK5jSYWgFoE8UTh/qcFZd3We0ZQXuuv1hg0Q1Odx9hWD
         gxNxIRM7etJ5jbUZjOO3Pq8V2Vu5rWEHmlzquZz0W6yCH42MPOpoe/TD1PqAt3BEPord
         8lYYnvMmh/ei0aarKRvya+3AE4LAhfqW9VzD5ls3ksSiPFVVgUwizhWuekZ4JhPRgBcl
         McalvL9G+p0c3yqXpJLxyStTNR6Ud5PKzy03teTxRabeaSuE4UGk2zEhWItEXcoAZJlY
         hv2g==
X-Gm-Message-State: APjAAAVnjjxdkGQRQrqRiRb5dvV2WAHc/uKHcjaxpcEb/CNIuZOl5hPl
	lo8tq3ur+VzvwNd9lGF2qH3VBa4lWNDQ61OD3FyjBznrgBWcEsKg8ZWB+QFWHOJ5csmAosnHu9a
	cqi/Hnyi6+Q4NMWRfn3cZ1giIFnLTZ//mGuwcSTh2FKjFeauKnG0g4gha71//lgk2izeG/UjyIP
	HVBT4Wq+d9SVSAm5aaZcG0uRcC8O/SUNtca1I4KkKYpxBdFCeQuWQgkxLOfuWQ4utJG9k4f2HwP
	bWXcxE7gAZFdhe+CYkAw2jw2UfucJVuqUFA5ff3Wh6Wc/S2KrRdjQK67O+qfpcCK9nQrDU/u8KA
	85CtTzYE1/7bub+cVuHLKtAwNaW/I7PLPRwpemU1zmv9jkgJFk5j6+vVcjvLYVVTdEvKiZnxRDL
	H
X-Received: by 2002:a63:f504:: with SMTP id w4mr5227720pgh.418.1551501570153;
        Fri, 01 Mar 2019 20:39:30 -0800 (PST)
X-Received: by 2002:a63:f504:: with SMTP id w4mr5227657pgh.418.1551501568931;
        Fri, 01 Mar 2019 20:39:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551501568; cv=none;
        d=google.com; s=arc-20160816;
        b=p2D2baxDlvLgpkF3YNAGfAhVDHgB0+7Ek5hlHOP4qenux+Asa13al2O4yQNOJVij1u
         MnyNGrblHWp/1JREdcFhKJNBQ74mPS0NieAp157fPB+NP5Bfo4hD7R7UCoORONzvsDRQ
         F5uj/oqOCu1L4AOCwlz85elcDDMATYCwgwiQCxfZk/opUFmJESXL99vy2nwIqa26a/vJ
         GLpaqKYIonDFPvynykvOLlZh/O6LC636/nGWYNBKW6Trrv9zMh/uORMKmSPo9xaoJMaK
         DX4+5M/d7k66Un1M8D/26suWY8gOK9Nap5P22F5bGQ7jKcXUlDCqch8tkJBa4ySNof8+
         nLdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=T80MdXzCnVwzBeJXMQTkL4J5G0aH3MXHjAFEpqlA0WA=;
        b=jmPWcXxoMuRnUIM4ekt0RPJVBrdlTmozBhZ/5I49M7h1xKfq/PkoYayZ/og8Mpvtl+
         urQlFewJ6f1GuXzFakB6iZl5qi35i++ZPay46eDb2yL8bNlWjIYbtaRCw0u/AsSHfUpk
         uJT/0kw+n6S2ahwrwzEfJdxo2+4VczE87PQRg0lfsj2EjEucTW9pyWfw0VZWVf51uVTy
         9l/8uSaZfDI9Gi2MWYxO6xjER6hrgdkpyp4nyh0hWImOlbQIFt2T2umIYQAnukoHtEHc
         tBsuM0kmxtHh1K/d2IpGYxkmCVj230otUP27xICSZ2O5gjboFvlnYTZkOcIH6B0nxDlE
         jTgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H54t1Lwp;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor36381501plr.61.2019.03.01.20.39.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 20:39:28 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H54t1Lwp;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=T80MdXzCnVwzBeJXMQTkL4J5G0aH3MXHjAFEpqlA0WA=;
        b=H54t1LwpYL9KnRhB0RSkACShPDrChkkfBpcCaNyX8vbf/4K1S8jijCEuv5s9YRWUzf
         IQfvZ5krjRlj8Rq2oNvTgneiBXMPVs25FPE3SWCoDewQ5uPMgCa1KdmdjKd1A+b0HuYW
         b84nrR/0hqbAO0WaKor8odL6NOOJbwfUSbrIlgyVF7GZPm5gvHCUc7MysgXpAblBzbD4
         H9dVCrvRfvxO5h+cnvrnW0jhXAYo457TNOL/m/9c3Lk7RSe396f4pj/1VvDRhEPWs3ao
         fcR476QUi6NVL5SAH72apw0w6maFPeOpjHRXh8/6cLrPQWt8a5q2LNaSLlsHov0ToFeK
         APZg==
X-Google-Smtp-Source: APXvYqxrbuCoMsX8jDfR607E+AkSPdih1iVDlTkR+/4MYXNh/xAM6MP7Wqzc9csPX45GlxJm4H/Zcw==
X-Received: by 2002:a17:902:b709:: with SMTP id d9mr9235818pls.83.1551501568725;
        Fri, 01 Mar 2019 20:39:28 -0800 (PST)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id a24sm29102508pfo.160.2019.03.01.20.39.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 20:39:27 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
To: vbabka@suse.cz,
	mhocko@suse.com,
	jrdr.linux@gmail.com
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: compaction: some tracepoints should be defined only when CONFIG_COMPACTION is set
Date: Sat,  2 Mar 2019 12:38:58 +0800
Message-Id: <1551501538-4092-2-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only mm_compaction_isolate_{free, migrate}pages may be used when
CONFIG_COMPACTION is not set.
All others are used only when CONFIG_COMPACTION is set.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/compaction.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6074eff..3e42078 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -64,6 +64,7 @@
 	TP_ARGS(start_pfn, end_pfn, nr_scanned, nr_taken)
 );
 
+#ifdef CONFIG_COMPACTION
 TRACE_EVENT(mm_compaction_migratepages,
 
 	TP_PROTO(unsigned long nr_all,
@@ -132,7 +133,6 @@
 		__entry->sync ? "sync" : "async")
 );
 
-#ifdef CONFIG_COMPACTION
 TRACE_EVENT(mm_compaction_end,
 	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
 		unsigned long free_pfn, unsigned long zone_end, bool sync,
@@ -166,7 +166,6 @@
 		__entry->sync ? "sync" : "async",
 		__print_symbolic(__entry->status, COMPACTION_STATUS))
 );
-#endif
 
 TRACE_EVENT(mm_compaction_try_to_compact_pages,
 
@@ -195,7 +194,6 @@
 		__entry->prio)
 );
 
-#ifdef CONFIG_COMPACTION
 DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 
 	TP_PROTO(struct zone *zone,
@@ -296,7 +294,6 @@
 
 	TP_ARGS(zone, order)
 );
-#endif
 
 TRACE_EVENT(mm_compaction_kcompactd_sleep,
 
@@ -352,6 +349,7 @@
 
 	TP_ARGS(nid, order, classzone_idx)
 );
+#endif
 
 #endif /* _TRACE_COMPACTION_H */
 
-- 
1.8.3.1

