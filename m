Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8853C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C302261FD
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BXs8yL23"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C302261FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 136ED6B0279; Thu, 30 May 2019 17:54:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E70B6B027A; Thu, 30 May 2019 17:54:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA3646B027B; Thu, 30 May 2019 17:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C03C16B0279
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:54:44 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id t17so3462889otp.19
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:54:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=+Hql3UnNz+U+1lYmmCsad2oNlY6bZIgkjk9Ecr29j+A=;
        b=UxTgNbaG6c3MpSW6k6/zlGPKJQi7X9ZgytTCnz8H4F9nwhPA3YcC/y25BrCxYJZOAX
         0/mL64s/5lfORb5CIaG3WSV0rG4T6RqoJyUBNmXjUsUaARIVdVCnazIOV3u8Wg4lqlcD
         5tWmMoOGFR4Fn3l0+sEqxIyZIKfuxx4a/jR1p13/xQiB54FfqKCN02MXna/MGZlqGvW6
         ScdKPpj6Ndv+1NYN0rQG7p2447ZzmNng2Tv58kIM9v1IjBMluLKtfdIpTK4LK6IftQNB
         84ARbnzv3f2OpUWIOF7K8kVdbX5ufEPVdB/oFb5A8cInnnFOO3kcFW/+nrEK2Y3bFZdo
         iknA==
X-Gm-Message-State: APjAAAV5GsrN3HZY4/doCLukiVvCup2Xx8UTAJXPLsTkegrhq4No/Wr/
	l+M6EVm7vpv5GxmI+Kq0uAzZJXP4hHmTWSDhPXz8hjBrgE5VZOGNSoNtCPbr9ynnxFgZawPgKYs
	G2l1sq02J9MRorSRbFNI0GCJaGUgwmPj9JRZ5fTzlyq8J74R1gFoNVfIWvRCB6x+Y7g==
X-Received: by 2002:aca:c3d7:: with SMTP id t206mr60926oif.129.1559253284466;
        Thu, 30 May 2019 14:54:44 -0700 (PDT)
X-Received: by 2002:aca:c3d7:: with SMTP id t206mr60902oif.129.1559253283651;
        Thu, 30 May 2019 14:54:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253283; cv=none;
        d=google.com; s=arc-20160816;
        b=oT9xwrBHh1ve2sRqVB4Gxl8Ndcwwn7dA0PqYWtVZxilxr6505hU9YgmmgLuz7Moxxa
         1m+HNS2B2isJ3TQ35U6EZtvlvUsqIFbpUTOhRE4Ve1CR5f4t4wGGdsAHXUmZ9LYgDM5n
         Vbhg0w1jHoHTcX5Pe8hB3tH3jw+M/CGgtjVGx4ou72Ei2SapWE0ZGhrTHkB/OZqYsJ4d
         8FNO/p+4wSveCuGPk1PokqxbIF6uzS0y4NAr1dAsdPkXI3i6SWLnmHpUScqKcwRQ2u9a
         2rWwZsTew2MMSFrCy/4UnhEMlxsUYsb00RQQDkRZM3HlSkHP/rkPsAtpJ6ofqedMEmez
         5Xfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=+Hql3UnNz+U+1lYmmCsad2oNlY6bZIgkjk9Ecr29j+A=;
        b=Ney+cVNEeykP78urVzQUFaYyIE3vshxrJsEhkjuRHfDMzx5FKT+MIRHtPA2z+xx6Fr
         SwlNW3HDwZVvhtOuDR2FkEgXscSOURUpCuOaKyH9j90Z3pUoShzP1orbG6jRZwZ/+85q
         E0I5mqlgn4w7EW4/KBycvYvO64ekh+eE4WqDTzp5ZVeNNoD2FYxpHktSsPbhOiv3ch4S
         bM5s17Sns+y9fkw6tUYEU57Jf0GMwJenSS6i0WCEfmTHMORIiwBml+q5e8EemRWDi/ke
         sSeBjtyklRlCYGF1Ie7qsaCgEjccEgdLNE86/A3tZISgXTwqWUEVRrTyKVBCePfzlZnc
         9G3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BXs8yL23;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor1968077otp.81.2019.05.30.14.54.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:54:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BXs8yL23;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=+Hql3UnNz+U+1lYmmCsad2oNlY6bZIgkjk9Ecr29j+A=;
        b=BXs8yL238Nx++nVmRKlg3dNF8CTnKOpeTXH0AG07gUebKWVwBReMaUvxW+ADvzwJwk
         HL7Z2/iu94p7I4zy38LSM+GFa9I3DNkDzScHJPMvIDd3EIXwnwx7TU9/jRgQ2bPHCNTN
         b2ZeQhQnwYYnXtsyLbJi6ZBBU7WMzu+BduNJjFj7Yb342UxFjbViJCZZ1aWCPfh3p5z3
         UqJZVkfskln9C5j/67ONPb9LHHYvE0bD2NGQUnSUtNRASvc24zb66/hAutak8OFQ70Mi
         +a9a/wdBysp+q2E181m0otXqpxVwLVHU5jpjDa7eHqaV2QssIfLYiRjA53oBXVcPZziH
         Oy6Q==
X-Google-Smtp-Source: APXvYqxGTR2Bptz8i/SgWXoKTL+4Bu+dJLGidAXFm62PcUBVrIR9eyVW68+tWL2IUSUeElRSKJsvlg==
X-Received: by 2002:a9d:5ec:: with SMTP id 99mr4311813otd.57.1559253283263;
        Thu, 30 May 2019 14:54:43 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id n7sm1450349oih.18.2019.05.30.14.54.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:54:42 -0700 (PDT)
Subject: [RFC PATCH 09/11] mm: Count isolated pages as "treated"
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:54:41 -0700
Message-ID: <20190530215441.13974.33609.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Treat isolated pages as though they have already been treated. We do this
so that we can avoid trying to treat pages that have been marked for
isolation. The issue is that we don't want to run into issues where we are
treating a page, and when we put it back we find it has been moved into the
isolated migratetype, nor would we want to pull pages out of the isolated
migratetype and then find that they are now being located in a different
migratetype.

To avoid those issues we can specifically mark all isolated pages as being
"treated" and avoid special case handling for them since they will never be
merged anyway, so we can just add them to the head of the free_list.

In addition we will skip over the isolate migratetype when getting raw
pages.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |    7 +++++++
 mm/aeration.c          |    8 ++++++--
 mm/page_alloc.c        |    2 +-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index be996e8ca6b5..f749ccfcc62a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -137,6 +137,13 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
 {
 	area->nr_free_treated++;
 
+#ifdef CONFIG_MEMORY_ISOLATION
+	/* Bypass membrane for isolated pages, all are considered "treated" */
+	if (migratetype == MIGRATE_ISOLATE) {
+		list_add(&page->lru, &area->free_list[migratetype]);
+		return;
+	}
+#endif
 	BUG_ON(area->treatment_mt != migratetype);
 
 	/* Insert page above membrane, then move membrane to the page */
diff --git a/mm/aeration.c b/mm/aeration.c
index aaf8af8d822f..f921295ed3ae 100644
--- a/mm/aeration.c
+++ b/mm/aeration.c
@@ -1,6 +1,8 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/memory_aeration.h>
+#include <linux/mm.h>
 #include <linux/mmzone.h>
+#include <linux/page-isolation.h>
 #include <linux/gfp.h>
 #include <linux/export.h>
 #include <linux/delay.h>
@@ -83,8 +85,10 @@ static int __aerator_fill(struct zone *zone, unsigned int size)
 			 * new raw pages can build. In the meantime move on
 			 * to the next migratetype.
 			 */
-			if (++mt >= MIGRATE_TYPES)
-				mt = 0;
+			do {
+				if (++mt >= MIGRATE_TYPES)
+					mt = 0;
+			} while (is_migrate_isolate(mt));
 
 			/*
 			 * Pull pages from free list until we have drained
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e79c65413dc9..e3800221414b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -989,7 +989,7 @@ static inline void __free_one_page(struct page *page,
 	set_page_order(page, order);
 
 	area = &zone->free_area[order];
-	if (PageTreated(page)) {
+	if (is_migrate_isolate(migratetype) || PageTreated(page)) {
 		add_to_free_area_treated(page, area, migratetype);
 		return;
 	}

