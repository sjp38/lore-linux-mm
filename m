Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20C68C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:47:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D94402187F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:47:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Zc4eXXrC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D94402187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 769066B0003; Thu, 27 Jun 2019 00:47:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 718FF8E0003; Thu, 27 Jun 2019 00:47:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 607018E0002; Thu, 27 Jun 2019 00:47:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 294846B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 00:47:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so750738pfm.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 21:47:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=1YRPtKSSZ8N5wTpxMenktTN/0UA8EWl9kZDCBk8+3+Y=;
        b=FavqXTZ4VGI/lv2dKXG6tOmREPpTAWB7WCxDPKt3clavcymrnrvfPRt5rPaDNICClE
         sIrB1ufv2gMT1jCvt//zEWMU1vC+YVarK5B7l6m3eFR0Nmkv3x44Z4lbhb4i+qTXeP1G
         kLtBgeDsnpxcLJn0e4Bkr83WRSTdnP0eQqsaSoc25GAzZc0VsTen3NQezzdXDsc49Egl
         yKebc124aHY5gNudqx/3G8qDAR3gw1tDBj3/DlaMMY8d7mi8IUk1vQNx7roNSm17gLGR
         nNenQjyVzw0l3kUZIBdfOxHaMUSVb2qpAu0sXc+1pR2tVpFCYzbnccnJ+Fnls5DCEfJp
         p24w==
X-Gm-Message-State: APjAAAU3MC0pg+HV8Z8gs4eue0rh6MnEG1ZHyYROvdNO3Kj2iKAhAk+R
	NsywC9Op4B5PwX+DRnIxdfwEZvVkUQAi3lTpT4HW5awqSbGLLLBjvAv/K69KnPCOBUn9b3Ucyqz
	bK9j4v2+l7Vx7ddyazb/x0g92lhQvx8+Uh9W5LvsfptvZL8Xmsfo9loPzuWT46N+28w==
X-Received: by 2002:a63:e0d:: with SMTP id d13mr1249946pgl.5.1561610853674;
        Wed, 26 Jun 2019 21:47:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1f0Vwb126YJHLqHaSzpukCC5d2JhItAUicdJ8EdT0DEwqOc25eJr3oGOh0tS0wiUy2gWB
X-Received: by 2002:a63:e0d:: with SMTP id d13mr1249909pgl.5.1561610853000;
        Wed, 26 Jun 2019 21:47:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561610852; cv=none;
        d=google.com; s=arc-20160816;
        b=x4xRpm7vRTcGB0wTtHjAkrkyFT2C2/WAUozaYcUKi/+w+Pvb3mqCeUHVjMY0bYrSbn
         SKWQHlCOD31wBhv8u2/CsP9pxeT2oDKMKhF5UYaAkbTKRjcaRhwD8WLzNLWzHCmN/F3m
         g7M7TXnP/gU903slXHCIZYTI60gMNg9tFa+RUJM1nvz61AjaJXU2B3VC46iiA8W1GOvv
         4NoPrI/0Q0Os9ixIc9+XUhy+K/OfVV5Cr3O4Q0yrL/tKPQ+VVW/lUBC5mc9QefTMfM6A
         9MiO48u1VsGHb34Z+COfJmxDIIEBRhBDAxT1LWyEXlQP681JnQRMc8O0aPaqX7uJjLhF
         LzYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=1YRPtKSSZ8N5wTpxMenktTN/0UA8EWl9kZDCBk8+3+Y=;
        b=bLtVU0VV+oPdRnnIamAunyEkUYsgjkYbT5rQSGs+U/n1ag1GH6W21TRG+0QAFfAqI6
         xqlmmtqjEu4fAIcIZcKJFoTF+lTyhtXoV7GlHVsyrK8dQOhH1sponkbtMlpFODEuMEK8
         VtG3R1Pm3okT29SUGEVtndOh8lP0Vt+kfje5L+AQ6lDxjUMI+DFRrh+6z6tHpKOvadsp
         rdUnfaRBXaipH0JFvXokRKZZV9jqr0qthCF4+IdcvDoC8wW6ymsjd+HoDgK3SNzjlZBp
         5hnfLe8uBGAlnrFNDAejSLKKMFTU0BH6jlHzYHQdZiWsyhbUYMvqCMOrcPSJRxX83Owl
         m48g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Zc4eXXrC;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d4si1294948pla.358.2019.06.26.21.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 21:47:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Zc4eXXrC;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-67-180-165-146.hsd1.ca.comcast.net [67.180.165.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 906C421855;
	Thu, 27 Jun 2019 04:47:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561610852;
	bh=ee2Mq/h/NzrSn+b/TDwwROThTXdyfId0zMmsuBEqsMU=;
	h=From:To:Cc:Subject:Date:From;
	b=Zc4eXXrCC+my0ISOPpsD7SHbwK4BXOHry6fuWv+QzJmA6E5k0q37IYowiw7w3iRlj
	 3WwcSJJ3XONzRL8zvUCluuh9GGE93md4NJt+0WpPuYMkACU9z1R9jW4eIe8BRfuT0L
	 fo2hfanS8R3FoK3oUJrGErGCyFUaaUdA8XeLL7Uo=
From: Andy Lutomirski <luto@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org,
	Kees Cook <keescook@chromium.org>,
	Florian Weimer <fweimer@redhat.com>,
	Jann Horn <jannh@google.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: [PATCH] mm/gup: Remove some BUG_ONs from get_gate_page()
Date: Wed, 26 Jun 2019 21:47:30 -0700
Message-Id: <a1d9f4efb75b9d464e59fd6af00104b21c58f6f7.1561610798.git.luto@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If we end up without a PGD or PUD entry backing the gate area, don't
BUG -- just fail gracefully.

It's not entirely implausible that this could happen some day on
x86.  It doesn't right now even with an execute-only emulated
vsyscall page because the fixmap shares the PUD, but the core mm
code shouldn't rely on that particular detail to avoid OOPSing.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 mm/gup.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..9883b598fd6f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -585,11 +585,14 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		pgd = pgd_offset_k(address);
 	else
 		pgd = pgd_offset_gate(mm, address);
-	BUG_ON(pgd_none(*pgd));
+	if (pgd_none(*pgd))
+		return -EFAULT;
 	p4d = p4d_offset(pgd, address);
-	BUG_ON(p4d_none(*p4d));
+	if (p4d_none(*p4d))
+		return -EFAULT;
 	pud = pud_offset(p4d, address);
-	BUG_ON(pud_none(*pud));
+	if (pud_none(*pud))
+		return -EFAULT;
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		return -EFAULT;
-- 
2.21.0

