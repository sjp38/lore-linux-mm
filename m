Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A78FC0030B
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2ADF21835
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LCqusXSt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2ADF21835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B2C26B0008; Sat,  7 Sep 2019 17:41:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 762796B000A; Sat,  7 Sep 2019 17:41:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 651116B000C; Sat,  7 Sep 2019 17:41:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id 413F66B0008
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:41:40 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 00B636D9B
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:40 +0000 (UTC)
X-FDA: 75909446718.11.tooth13_48b40fbcc6a5a
X-HE-Tag: tooth13_48b40fbcc6a5a
X-Filterd-Recvd-Size: 4774
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:39 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id 4so5469420pgm.12
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 14:41:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=roF+iHytDA2OpX6EAs6vae/MbSREfIb/2EmgYW70LGY=;
        b=LCqusXStz2S5t5Jo03KSnHbdxvW5JnsBIMaaxJRM/k++WE4/icVGE/B9clTcqDPqzr
         e+6bcZNXENyZPcxqezTzfGSBa1s2TTVHZSswaU1Q/gsVktt+7t4uh6VhJs2wcOEH+rK2
         7EINf8UFuBSovxqmpSsvGmkG7tPc2yxjQt9m58rxPK7IS7zOWR4d+Fv0Qwyp7lzd0wnl
         KHjiirC1iZTH9ejrMEEPJ859Vod3vSehrRREj21RGvtTebumbB5EmAPCweCBjVlNlnoX
         xhc2cIqSXEGo0SCZjGNrGJGibWee8BvXhvv/LQ1Qyc2aoKu/JzyGwG0fBb4wq6PYyw7Q
         Nl1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:in-reply-to:references;
        bh=roF+iHytDA2OpX6EAs6vae/MbSREfIb/2EmgYW70LGY=;
        b=G6nVWcXgPaQa99EPC2YeE9xec8KcLm88Zdpf4dPLFFDf+M/y71rHFW0HT/f/C+cfAO
         JMScdJ6Fy/nGBvde64N+Pal8NWmG5e1XiOYOqyCORz/Vjh3KhEGbH6fSFPvTQ/PVM1zk
         XMGuTd2yZMhYBEYnmuARwdTIWxH1F68+j/mH9Vgx69IMySlJCLsHL6oG31sKxoJoW6Lu
         KkVHGLylvdOY/9VfcztnzuxEkFVb4D8Qh2WZfnJzyoVltMH4hfH8djEPMilY5TmIKXCL
         uy0qZtkvReYK5rqy2cq0VYfZLXxa+DUgzMf2ANgvjX0EUSWrMIT5buyn5Vj/vy90JGuK
         wWtQ==
X-Gm-Message-State: APjAAAVOFEnTNKVOOcgrBaTFk+DsNn0xj48a2l2b03UDj20rKl5IVZqB
	XPrhqVQ9NkgUWTD56uB086k=
X-Google-Smtp-Source: APXvYqyFSnMx/7lAMSE2e3lPA0RN+xaQcUoIMVlsQ0qfqgUp72SQW3UUmlrUThMTSeTxYPzNir9e5Q==
X-Received: by 2002:aa7:955d:: with SMTP id w29mr18821170pfq.60.1567892498622;
        Sat, 07 Sep 2019 14:41:38 -0700 (PDT)
Received: from localhost.localdomain ([112.79.80.177])
        by smtp.gmail.com with ESMTPSA id h11sm9078516pgv.5.2019.09.07.14.41.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 07 Sep 2019 14:41:37 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com,
	sashal@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com,
	sstabellini@kernel.org,
	akpm@linux-foundation.org,
	david@redhat.com,
	osalvador@suse.com,
	mhocko@suse.com,
	pasha.tatashin@soleen.com,
	dan.j.williams@intel.com,
	richard.weiyang@gmail.com,
	cai@lca.pw
Cc: linux-hyperv@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 3/3] mm/memory_hotplug.c: Remove __online_page_set_limits()
Date: Sun,  8 Sep 2019 03:17:04 +0530
Message-Id: <9afe6c5a18158f3884a6b302ac2c772f3da49ccc.1567889743.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1567889743.git.jrdr.linux@gmail.com>
References: <cover.1567889743.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1567889743.git.jrdr.linux@gmail.com>
References: <cover.1567889743.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As both the callers of this dummy __online_page_set_limits()
is removed, this can be removed permanently.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/memory_hotplug.h | 1 -
 mm/memory_hotplug.c            | 5 -----
 2 files changed, 6 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f46ea71..8ee3a2a 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -105,7 +105,6 @@ extern unsigned long __offline_isolated_pages(unsigned long start_pfn,
 extern int set_online_page_callback(online_page_callback_t callback);
 extern int restore_online_page_callback(online_page_callback_t callback);
 
-extern void __online_page_set_limits(struct page *page);
 extern void __online_page_increment_counters(struct page *page);
 extern void __online_page_free(struct page *page);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c73f099..dc0118f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -604,11 +604,6 @@ int restore_online_page_callback(online_page_callback_t callback)
 }
 EXPORT_SYMBOL_GPL(restore_online_page_callback);
 
-void __online_page_set_limits(struct page *page)
-{
-}
-EXPORT_SYMBOL_GPL(__online_page_set_limits);
-
 void __online_page_increment_counters(struct page *page)
 {
 	adjust_managed_page_count(page, 1);
-- 
1.9.1


