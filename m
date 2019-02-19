Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE632C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:33:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AF7A2146F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:33:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AF7A2146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axis.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D159C8E0003; Tue, 19 Feb 2019 07:33:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C74288E0002; Tue, 19 Feb 2019 07:33:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B180B8E0003; Tue, 19 Feb 2019 07:33:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7BD8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:33:53 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id i203so2300789lfg.10
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:33:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=mmnpFmKUxANUL/kLhFIKB50P+1U0QzpgwHLTzVifXS8=;
        b=A4ialgNQCNfnuPIWYGqcaib2wrwpM9Ri5bAP0Su07Gf1qgyOOK2qU9yaMSqgPjybsu
         6t8oFg6gTlMXwbA6eqgSqd/W+g2uLYVdj8EEmB+O0Jvy4DdJo1iF2IcwxAroqJ7oksPe
         qf7oI/RlNZVhv7Gez99KzwfficqZANip4ZCjlBF8VHwMY5E14Izd6upOzrrc5ehn8rb4
         9NIbWJOlcR/kRVzc8qPkqva7WqFfEG6s0tWzrF+B3qWpPtmeGoPc6rEmxGaKMXQLYH+l
         cP3bXs/FDG/fSjZu8m6ZTYLY+4YHkJpr5HoI6qxzGbW2JXgaCYhoteKdIXNg7dH8mlSb
         dJVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
X-Gm-Message-State: AHQUAubvypsKnXnqLWl1WOr8bOwFaVTjZNiePsPp3dqzekgwYsROEMqL
	7/UAyol+D5ukkkvL19EMKx9CVll3yw8U2sSHbDtrzGYlTS2UPZnI6BRHf9lZehA2B1VxT01USVA
	wFXOU9nMP2178hVRtS9DT5HfUOVp5HQeybWIpM7K+YQ0A4S9PzPwifQQMmmAbT9kxsQ==
X-Received: by 2002:a2e:9786:: with SMTP id y6-v6mr17042975lji.53.1550579632394;
        Tue, 19 Feb 2019 04:33:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaeN2C+0v09I4pbhjAW2BLWoLdkAFG+II4TfJa8n5QiiuzVImlijkj2M5IEGLk7KT5kG3d0
X-Received: by 2002:a2e:9786:: with SMTP id y6-v6mr17042920lji.53.1550579631266;
        Tue, 19 Feb 2019 04:33:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550579631; cv=none;
        d=google.com; s=arc-20160816;
        b=VvyFdo8qhC54/eCPO2Gk/wI3j8I35OWJXIn6Wt8wYQBnu5lDnuwuZEUxNYqdhvQDgP
         ZlS4jUFkh8kYD7mSdCkBsRgIS9Y8vrgTLUUegjAa///AZQye0/Az50wdRPzmC9nhilyR
         VuDZRJxwYp/IiuDts+aPdI8hWrrREqoXzwuGX/4O3/SBnYVCiCLEuj0ShXZ8p5gsUQm0
         +psl9PVtNG/YOqxPPymQVdupvlPbDstOx/vAhdddmiT7SRQblUiXfMbHp7G9zI7V4n8a
         eAZDi6mDjIJpPITMo7N1job3UbJCtZbYOixtwDzM0icxz9LsSz1/OVHqWR5kmTXIr2LB
         Dtdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=mmnpFmKUxANUL/kLhFIKB50P+1U0QzpgwHLTzVifXS8=;
        b=e6mJTTZQcp8VZYtFZD0qiLj6tAfO+x/SxueyTkuOAI++Ia9N17OLP+sjRCx7/KSqUi
         NYsnbZVBaq+sNhvNN6R5bXZNaOhyl8z46xHgreWYfx5DfDqEG/HzZgOCFD6q0g0Jxh8f
         WLqpT4eF5NaskODiOslDVQ10kB+W2QB2KKu0v4jPqbx2HZYthbiLhxneDBlyFDQCAYC7
         Z9vb5V0syaIRP532Tc0WctgYQju6xA7yxZRtIsVyXSgZswd2tXnwvC3E+NcxIjUMqFDQ
         lZbCuX1ppg83Xp2sSkxyjWUfY5fDxJpsaBWJtRj36RiYP/hTC3YsKtZr5VqzIg9cnILN
         AKGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id p9-v6si9334578ljh.81.2019.02.19.04.33.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 04:33:51 -0800 (PST)
Received-SPF: pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) client-ip=195.60.68.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from localhost (localhost [127.0.0.1])
	by bastet.se.axis.com (Postfix) with ESMTP id D4D25184D9;
	Tue, 19 Feb 2019 13:33:50 +0100 (CET)
X-Axis-User: NO
X-Axis-NonUser: YES
X-Virus-Scanned: Debian amavisd-new at bastet.se.axis.com
Received: from bastet.se.axis.com ([IPv6:::ffff:127.0.0.1])
	by localhost (bastet.se.axis.com [::ffff:127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id wdBCkFgbkWvd; Tue, 19 Feb 2019 13:33:48 +0100 (CET)
Received: from boulder03.se.axis.com (boulder03.se.axis.com [10.0.8.17])
	by bastet.se.axis.com (Postfix) with ESMTPS id 45382184D4;
	Tue, 19 Feb 2019 13:33:48 +0100 (CET)
Received: from boulder03.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 141331E06E;
	Tue, 19 Feb 2019 13:33:48 +0100 (CET)
Received: from boulder03.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 089711E06A;
	Tue, 19 Feb 2019 13:33:48 +0100 (CET)
Received: from thoth.se.axis.com (unknown [10.0.2.173])
	by boulder03.se.axis.com (Postfix) with ESMTP;
	Tue, 19 Feb 2019 13:33:47 +0100 (CET)
Received: from pc32929-1845.se.axis.com (pc32929-1845.se.axis.com [10.88.129.17])
	by thoth.se.axis.com (Postfix) with ESMTP id F02401C76;
	Tue, 19 Feb 2019 13:33:47 +0100 (CET)
Received: by pc32929-1845.se.axis.com (Postfix, from userid 20456)
	id EBF60409B8; Tue, 19 Feb 2019 13:33:47 +0100 (CET)
From: Lars Persson <lars.persson@axis.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: linux-mips@vger.kernel.org,
	Lars Persson <larper@axis.com>
Subject: [PATCH] mm: migrate: add missing flush_dcache_page for non-mapped page migrate
Date: Tue, 19 Feb 2019 13:32:12 +0100
Message-Id: <20190219123212.29838-1-larper@axis.com>
X-Mailer: git-send-email 2.11.0
X-TM-AS-GCONF: 00
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003504, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Our MIPS 1004Kc SoCs were seeing random userspace crashes with SIGILL
and SIGSEGV that could not be traced back to a userspace code
bug. They had all the magic signs of an I/D cache coherency issue.

Now recently we noticed that the /proc/sys/vm/compact_memory interface
was quite efficient at provoking this class of userspace crashes.

Studying the code in mm/migrate.c there is a distinction made between
migrating a page that is mapped at the instant of migration and one
that is not mapped. Our problem turned out to be the non-mapped pages.

For the non-mapped page the code performs a copy of the page content
and all relevant meta-data of the page without doing the required
D-cache maintenance. This leaves dirty data in the D-cache of the CPU
and on the 1004K cores this data is not visible to the I-cache. A
subsequent page-fault that triggers a mapping of the page will happily
serve the process with potentially stale code.

What about ARM then, this bug should have seen greater exposure? Well
ARM became immune to this flaw back in 2010, see commit c01778001a4f
("ARM: 6379/1: Assume new page cache pages have dirty D-cache").

My proposed fix moves the D-cache maintenance inside move_to_new_page
to make it common for both cases.

Signed-off-by: Lars Persson <larper@axis.com>
---
 mm/migrate.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..80fc19e610b5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -248,10 +248,8 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 				pte = swp_entry_to_pte(entry);
 			} else if (is_device_public_page(new)) {
 				pte = pte_mkdevmap(pte);
-				flush_dcache_page(new);
 			}
-		} else
-			flush_dcache_page(new);
+		}
 
 #ifdef CONFIG_HUGETLB_PAGE
 		if (PageHuge(new)) {
@@ -995,6 +993,13 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		 */
 		if (!PageMappingFlags(page))
 			page->mapping = NULL;
+
+		if (unlikely(is_zone_device_page(newpage))) {
+			if (is_device_public_page(newpage))
+				flush_dcache_page(newpage);
+		} else
+			flush_dcache_page(newpage);
+
 	}
 out:
 	return rc;
-- 
2.11.0

