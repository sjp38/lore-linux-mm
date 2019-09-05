Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE9EFC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:37:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2E742070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:37:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NwYg3DPG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2E742070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4742C6B0003; Thu,  5 Sep 2019 14:37:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4258A6B0005; Thu,  5 Sep 2019 14:37:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EC6F6B0007; Thu,  5 Sep 2019 14:37:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id 10CB66B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:37:11 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 72F4555FBB
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:37:10 +0000 (UTC)
X-FDA: 75901724220.12.form71_5bae9978cc32d
X-HE-Tag: form71_5bae9978cc32d
X-Filterd-Recvd-Size: 3573
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:37:09 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id q10so2346168pfl.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 11:37:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=cdXMooijOVCDDklAhZuef4glr7GEYQsndAFC5Dzs39I=;
        b=NwYg3DPGtouRXEFmIVaeTkxg/FzR6vJ0B1wp1Jb423FCaSfHNTzFGTFBNPWy3159fl
         H9KmXPmRRPWz93zBA6+IcK/rjm2iBELYPk4ycDH2nRYHnJDLYulNdn2c3WPKjLp9els/
         lc60ZGbr5PShXttY3+d7K4II+2+gEoVTMUr5JvnMKaVa3g784WbXSNZWwSyieJDH2Dt4
         lsleHHKSV9+VcIRGcpKwxB0qWXBdxngPcXtsk+dlbQOCzNTqjSK9QymsT0aJqTD+6Awe
         z8aEDm324f48MDpYMuHo633InHRSqfaidV9OwVqJh8wy0bo2oIkppaKBjqkYPWQWOu7+
         Hxkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=cdXMooijOVCDDklAhZuef4glr7GEYQsndAFC5Dzs39I=;
        b=Ha1p1Ult/goNtFwCkQAxkGRbiJITNdprs4qmx7HoUMLRWZWDqtxMvdES7G32frzinq
         BIBL2gBw5evfUJrsvnOtWibTwV+2Z8gyNWxwknUmawuDowdqw1FZFc7SNMzIMyXfRVy1
         Jky4lBMLsSlLa+pU9dIz5AXY1Y+SByI/GNac1A2uKe4XQ1CDY0ANvrhV2Behck2NqrkC
         LvBiPSOGdu0Sswrnq/JdwDhBlVn+5l6LR8uG1v48T8/oAX3o/PEdK6F7nvcfklS6nx7v
         SVnMkG4VErKR7ieKlDyd9OJsZkeQ1BIMvK4K6YeOEhtD2LKrVujD/QjVJXp6pMgV1Zfc
         HY5w==
X-Gm-Message-State: APjAAAVu7NUDXoD4d66krC+FVbdJyuLOH0jnybA9faWrij4O1amRg2yh
	2RB6DfVDN3bzG7TZ5CmD21w=
X-Google-Smtp-Source: APXvYqw+buhM4MmEZlgwtHc9HIsoOVpXQbIrVDPW9qehdHehSaoXp043dp5dL6H28Ob+jCYqwfSCRw==
X-Received: by 2002:a63:eb51:: with SMTP id b17mr4366305pgk.384.1567708628796;
        Thu, 05 Sep 2019 11:37:08 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([106.51.17.197])
        by smtp.gmail.com with ESMTPSA id k64sm7386471pge.65.2019.09.05.11.37.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Sep 2019 11:37:07 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org,
	rcampbell@nvidia.com,
	jglisse@redhat.com,
	mhocko@suse.com,
	aneesh.kumar@linux.ibm.com,
	peterz@infradead.org,
	airlied@redhat.com,
	thellstrom@vmware.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm/memory.c: Convert to use vmf_error()
Date: Fri,  6 Sep 2019 00:13:00 +0530
Message-Id: <1567708980-8804-1-git-send-email-jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vmf_error() here.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 mm/memory.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b..1302be32 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1750,13 +1750,10 @@ static vm_fault_t __vm_insert_mixed(struct vm_area_struct *vma,
 	} else {
 		return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
 	}
-
-	if (err == -ENOMEM)
-		return VM_FAULT_OOM;
-	if (err < 0 && err != -EBUSY)
-		return VM_FAULT_SIGBUS;
-
-	return VM_FAULT_NOPAGE;
+	if (!err || err == -EBUSY)
+		return VM_FAULT_NOPAGE;
+	else
+		return vmf_error(err);
 }
 
 vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-- 
1.9.1


