Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DA71C4151A
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29E59218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29E59218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E8698E0004; Thu, 31 Jan 2019 13:37:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24A408E0001; Thu, 31 Jan 2019 13:37:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EB578E0004; Thu, 31 Jan 2019 13:37:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF97F8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 13:37:19 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so4681948qtb.9
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:37:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kXqLfs1BKp0kzy9udszLKBSqjJnqMxtry13bQ0e2bt8=;
        b=VD7CPTUbQZwoe/6C6M58onbZGXw+sVwyjl869HKiRbaShnQAyF/rkEbsZZ/uAgDHFw
         d9b0uX9WzTebh0kG19fyKc2G/17XwM3ksbu4UyEa7xRgohflPLB9MVf4xiNWWg00U/0e
         eRJl+8r7bVzlL9uYKcKeQmiZiG3A2Tw9JDSrq27b40rUyckuzt87bS0d0fJQzefBZ7bx
         qi9uPG74jHy+CENYHMcbWlZ1ccQPQlpShi7Y034I8ZF83dLdetaniQ5npwr78C/q8FLA
         xnh79PHIn1VfFg0yQsLG3FiU5j6mvCEXyqR2SlIKNYFCXm8AiTpsHcigBZGnF+M06K1b
         TWNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdeFRKq6tWdK+BArcvLizSCV8XHtpdigoSu5sqfp4Oz8CY3FabJ
	7AoY6RFSCfzkAXAYXjsT2AoiYKkK+9nghU7TyZZ37ld272YAh5jZoqD+AHR0Y8B3lIPrhTTSJKH
	J56/tmH+j5k/pEYwDNLjttOY/ow2ULpzko+b/w4L//H9nTPGVrfWlu4Taw1Fw/vpDcA==
X-Received: by 2002:a0c:b527:: with SMTP id d39mr33813356qve.201.1548959839625;
        Thu, 31 Jan 2019 10:37:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6aZV+mdzMQN6JdSlGoG0iDsn7Mq5dSJP16dNNQ7l8jI3JH1LPCmu6cSamnpjijm7CuId1i
X-Received: by 2002:a0c:b527:: with SMTP id d39mr33813336qve.201.1548959839203;
        Thu, 31 Jan 2019 10:37:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548959839; cv=none;
        d=google.com; s=arc-20160816;
        b=H2QZ2V86KTj77DC0tuZjDEaF8xu5Zn/GDiauLi3gKOJGhwEs6MewKduLXSJfX4eEVr
         rCiRrzDyCvZKuPJzsYiJTxH6+sde92RAsOUdWFjg6ljM0Cxk58OT7Xtbsu0/jVyC/xBK
         /LfoVXeykevxz0t7AF7jYWpv27zGbQXzD1ICvgggi4HpNM2C6WGa8N/jwysbHuP5aE9v
         HvU8zw6uwB3rVnZ7FHV9IfyfBPfFlFSj8jxcrAtpA6DO6SU50Ax/5A542kZKUwc5uQiM
         WOtGTPGKMmFJqLL9D6gbxXCRkKT61ccYASGPFsHHNqMcv3oSsdZYEbZtIhj1UPgXwkWi
         jX9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kXqLfs1BKp0kzy9udszLKBSqjJnqMxtry13bQ0e2bt8=;
        b=Ns/S1vOe7rXX3JVVl40wa4BRIlMsVXryLxYD756FM1HuXerFXcULvqFfxP45rAftcO
         U0f1gc2H6DcvlfBdY/Qf2AAAzMwTh4E0h+7M20xq1as5tcbJP2KVfbnUnKsQTU+G75Vy
         c+TzkyRd2oDswAR/eGbZ4xzW1osuLdvUDQPwYKsiWIZKsK3EwiVpsgcCOPCMeVIBnZ5X
         39h530aCDqcJ8MbVaOmIruJyYcvCW0a9/eUv44M6i4Gqcs1F2k6nda3O11Qf+sYMFwg1
         Kn15iCJEqvVUvEhdcD0IHuiOUMK4qbrA1ghtVF9Y8x48zTJQKp580pWEY820uHUbkORG
         QO7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e16si1800838qtr.3.2019.01.31.10.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 10:37:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6B0E99090D;
	Thu, 31 Jan 2019 18:37:18 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6934718506;
	Thu, 31 Jan 2019 18:37:17 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	kvm@vger.kernel.org
Subject: [RFC PATCH 2/4] mm/mmu_notifier: use unsigned for event field in range struct
Date: Thu, 31 Jan 2019 13:37:04 -0500
Message-Id: <20190131183706.20980-3-jglisse@redhat.com>
In-Reply-To: <20190131183706.20980-1-jglisse@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 31 Jan 2019 18:37:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Use unsigned for event field in range struct so that we can also set
flags with the event. This patch change the field and introduce the
helper.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: kvm@vger.kernel.org
---
 include/linux/mmu_notifier.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index be873c431886..d7a35975c2bd 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -6,6 +6,7 @@
 #include <linux/spinlock.h>
 #include <linux/mm_types.h>
 #include <linux/srcu.h>
+#include <linux/log2.h>
 
 struct mmu_notifier;
 struct mmu_notifier_ops;
@@ -38,8 +39,11 @@ enum mmu_notifier_event {
 	MMU_NOTIFY_PROTECTION_VMA,
 	MMU_NOTIFY_PROTECTION_PAGE,
 	MMU_NOTIFY_SOFT_DIRTY,
+	MMU_NOTIFY_EVENT_MAX
 };
 
+#define MMU_NOTIFIER_EVENT_BITS order_base_2(MMU_NOTIFY_EVENT_MAX)
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -60,7 +64,7 @@ struct mmu_notifier_range {
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
-	enum mmu_notifier_event event;
+	unsigned event;
 	bool blockable;
 };
 
@@ -352,7 +356,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 
 static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
-					   enum mmu_notifier_event event,
+					   unsigned event,
 					   struct vm_area_struct *vma,
 					   struct mm_struct *mm,
 					   unsigned long start,
-- 
2.17.1

