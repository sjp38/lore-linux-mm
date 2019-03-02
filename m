Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65B07C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:39:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C09A2086D
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:39:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="MSvbRfFs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C09A2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94CB18E0004; Sat,  2 Mar 2019 17:39:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FBAC8E0001; Sat,  2 Mar 2019 17:39:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EA1E8E0004; Sat,  2 Mar 2019 17:39:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 558448E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 17:39:38 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id q15so1462316qki.14
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 14:39:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=DK+5XMVgtWeHEsPD9waEnnFYsNsVEJ351y7fqi8ULmY=;
        b=pI7QeCXbOZu+R0yJjXKe8YmfsaPLTzcyT3hg07GN4cIvUDaMdeoS4fjwp9nk0/ll8R
         nYZyg9T9ODlANsdyEiImprupaMOzXheyAOPuDuhmBs2QdTkEXOUIKf5xTB8Ehs2s9h1i
         mehmoQNHLL3UJl+rluXoIC9oqapN5LiktJKlFThKc7z09fhrsECTj2+MLGlwpzHlAGUd
         7NzvZh6TWJBfZh1q4QK0ljkbpa3WHUQ/1BfZCLlVJslhpaLN+Vggav2TkSz0DxyUFqUD
         jQD1jZr0nBSP/28elI/tWVa6PGnd6hBiaGPwgGnrofI5LzoulSuwFK8QoTk6mymJbtBR
         XXEg==
X-Gm-Message-State: APjAAAWXSB0j7LIGpAM8by2nlXsdkV3KJm5oeU68LJbOhFOT4R2hpc/g
	WpcsV5sHeb93T0o/gl+yCM5LVMbWx4AOUYtIa2rYm62OtWV+A+/t2XtT4cT3q7h6JKlTw3uqpyH
	P2vhKJlxErQVbtGKocN3vKl892WwbZ0jz9VFAEjKHe/G/1+9YVVube3iIj4tbUWQgNPrMEuM5lB
	Xt+NI/hFVOb7nCiBxOG7RX1lx1POX5PMtBEjZuGY/K3kR5qTk4pJPOqdtCdqNcJRQy8NPx/UNKa
	cTjwAHlzoebwsG+2lKBFtxF4yHzh9iSIzIFbnRMfuzjkvrjLtl/4ujgoLKmBExVcyZPd5d+DPKb
	kWEVWLvXW7GSAtc37jdwHhPGln05S1PGUu+Y3gmGLEyMCX2EFF5ulODddlxHTn5yaaz8Ja+keA0
	h
X-Received: by 2002:ac8:3122:: with SMTP id g31mr9672285qtb.273.1551566378070;
        Sat, 02 Mar 2019 14:39:38 -0800 (PST)
X-Received: by 2002:ac8:3122:: with SMTP id g31mr9672260qtb.273.1551566377335;
        Sat, 02 Mar 2019 14:39:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551566377; cv=none;
        d=google.com; s=arc-20160816;
        b=a0GVGOPAcrNIN7IO1Ohg8UY9WTdC1eHnA8t6wPLXXlVYitZAXbXT0DyAu4jvdSD1KI
         PB+tuyGUvF8zRoUAy/tox9qJrXel/hNtW3kUdL4sZsqgtRd1465vA6XiOBmWDFnb3juX
         iLiCPA1SEp7vuSpZVdvR3RvCqrN2FeVrzLY7IB+eE/xOlCCBC8C8QQ3OFtkE790q+fL9
         8RA6BlQW1bObyXYoMrBNo49Tv2TVhq1KTSqUbTlxADChpe/xHMsWukMI1xHS6iHLWX6/
         xkxTc8sCTMxqeGOCCk0bJx9WR77YUvbxMnvURmmSXihaa+4Nyt7A2VJBwAt7x72v3zEZ
         TSCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=DK+5XMVgtWeHEsPD9waEnnFYsNsVEJ351y7fqi8ULmY=;
        b=xux6ccMNAQtZCU10vdEzwXxyI7fJNAFVGx4GM/LhNkfkU4VfJFkWjUvBT1FVVfkDG5
         vte8KAuYu5WjkyHUdMIwSPPx3ychsfiwQMcoZZ6Me29QEaAq1VzRuFLZoXoNU1FgFoxS
         UcuquiIhSLEkhFLcaWjBtiT3iCMbWvRaeSTBFbROo0XL/hozG84173LECe7AJQywbslD
         A/7WKCzGjB75vgBHk/41B4307Hv8AnoA2Fhnxxo4t+t3bwayTyjT2MgYZCtMhMNRJKVM
         +4ErtO0VB1uqvRZ/oQneTUbPWJTjMZM11CCmkH0z/Ppn7CZUo/qso1z7KE68jgqzd3+7
         3bFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=MSvbRfFs;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f11sor1099966qkb.35.2019.03.02.14.39.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Mar 2019 14:39:37 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=MSvbRfFs;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=DK+5XMVgtWeHEsPD9waEnnFYsNsVEJ351y7fqi8ULmY=;
        b=MSvbRfFsKZq4q8WcfA+qRoCom/ZwzH9c7N+J1P0pp5DfZJbwGhf/9k8NB8t1a13cdl
         OaEusB/BKn3xCvhVjSayHSTdN1CfhgweRPx4u5e24RNMcwZJH7OAR/lH1IahCOsngVWy
         9hVk9ma42j+BFS6RqnSxdzvqc/1tQhTKk8P95sdMPkijVDQaRyicr+156OQg121QxZq3
         tkAW7+Yz8NdcAWQ1s3dnWbjHMdwwIvj6U07mKP8y9kpYskZzjfW6d9bSvCP1KiBux67c
         zYrqQaCPkBO9UBVlXnJf/TlMiR9EIh10dsRCKv7h5Q9IhpJlrWtfsjM1n9IQjw6rdV1o
         RlQw==
X-Google-Smtp-Source: APXvYqxkw5sm1LIULdONWmeSqiNZNneM8+u3QafTNRkKR1AQt22sY3jZ6rsUmuuN9v2TJIHsmx3SOQ==
X-Received: by 2002:a37:f506:: with SMTP id l6mr9187794qkk.110.1551566377048;
        Sat, 02 Mar 2019 14:39:37 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id l36sm1009683qte.82.2019.03.02.14.39.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 14:39:36 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/hotplug: don't reset pagetype flags for offline
Date: Sat,  2 Mar 2019 17:39:20 -0500
Message-Id: <20190302223920.5704-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000104, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded
memory to zones until online") introduced move_pfn_range_to_zone() which
calls memmap_init_zone() during onlining a memory block.
memmap_init_zone() will reset pagetype flags and makes migrate type to
be MOVABLE.

However, in __offline_pages(), it also call undo_isolate_page_range()
after offline_isolated_pages() to do the same thing. Due to
the commit 2ce13640b3f4 ("mm: __first_valid_page skip over offline
pages") changed __first_valid_page() to skip offline pages,
undo_isolate_page_range() here just waste CPU cycles looping around the
offlining PFN range while doing nothing, because __first_valid_page()
will return NULL as offline_isolated_pages() has already marked all
memory sections within the pfn range as offline via
offline_mem_sections().

Since undo_isolate_page_range() is rather unnecessary here, just remove
it. Also, fix an incorrect comment along the way.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memory_hotplug.c | 2 --
 mm/sparse.c         | 2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 736e107e2197..e793f6514fb2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1643,8 +1643,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
-	/* reset pagetype flags and makes migrate type to be MOVABLE */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
diff --git a/mm/sparse.c b/mm/sparse.c
index 77a0554fa5bd..b3771f35a0ed 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -556,7 +556,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-/* Mark all memory sections within the pfn range as online */
+/* Mark all memory sections within the pfn range as offline */
 void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
-- 
2.17.2 (Apple Git-113)

